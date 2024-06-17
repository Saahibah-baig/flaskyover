import React, { useState, useEffect } from 'react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, Brush } from 'recharts';
import { CSVLink } from "react-csv";
import DatePicker from 'react-datepicker';
import Select from 'react-select';
import 'react-datepicker/dist/react-datepicker.css';
import { Link } from 'react-router-dom';
import Policy from './Policy';
import './AppOverview.css';
import data1 from './data.json'; 
import data2 from './data2.json'; 

const AppOverview = () => {
  const [selectedAppId, setSelectedAppId] = useState(null);
  const [startDate, setStartDate] = useState(new Date());
  const [endDate, setEndDate] = useState(new Date());
  const [data, setData] = useState([]); 
  const [dateRangeType, setDateRangeType] = useState('daily'); // Default to daily data

  const appOptions = [
    { value: '12345', label: 'AppID: 12345' },
    { value: '67890', label: 'AppID: 67890' }
  ];

  useEffect(() => {
    if (selectedAppId === '12345') {
      setData(data1);
    } else if (selectedAppId === '67890') {
      setData(data2);
    } else {
      setData([]); 
    }
  }, [selectedAppId]);

  const handleCalculate = () => {
    // Filter data based on selected date range type (daily, weekly, monthly)
    const filteredData = data.filter(d => {
      const date = new Date(d.name);
      const filterStartDate = new Date(startDate);
      const filterEndDate = new Date(endDate);

      if (dateRangeType === 'daily') {
        return date >= filterStartDate && date <= filterEndDate;
      } else if (dateRangeType === 'weekly') {
        const weekStart = new Date(filterStartDate);
        weekStart.setDate(filterStartDate.getDate() - filterStartDate.getDay()); // Start from Sunday
        const weekEnd = new Date(filterEndDate);
        weekEnd.setDate(filterEndDate.getDate() - filterEndDate.getDay() + 6); // End on Saturday
        return date >= weekStart && date <= weekEnd;
      } else if (dateRangeType === 'monthly') {
        return date.getFullYear() === filterStartDate.getFullYear() && date.getMonth() === filterStartDate.getMonth();
      }
      return false;
    });
    
    setData(filteredData);
  };

  const peekLoad = data.length > 0 ? Math.max(...data.map(d => d.usage)) : 0;
  const minLoad = data.length > 0 ? Math.min(...data.map(d => d.usage)) : 0;
  const costIncurred = data.reduce((acc, d) => acc + d.usage * 0.5, 0);
  const potentialSavings = data.reduce((acc, d) => (d.usage < 50) ? acc + (d.usage * 0.5 * 0.3) : acc, 0);
  const exportData = data.map(d => ({ date: d.name, usage: d.usage }));

  return (
    <div className="app-overview">
      <div className="header">
        <div className="app-info">
          <Select 
            options={appOptions} 
            value={selectedAppId}
            onChange={(option) => setSelectedAppId(option.value)}
            placeholder="Select App ID"
          />
          <div className="date-picker">
            <DatePicker
              selected={startDate}
              onChange={(date) => setStartDate(date)}
              selectsStart
              startDate={startDate}
              endDate={endDate}
              placeholderText="Select start date"
            />
            <DatePicker
              selected={endDate}
              onChange={(date) => setEndDate(date)}
              selectsEnd
              startDate={startDate}
              endDate={endDate}
              minDate={startDate}
              placeholderText="Select end date"
            />
            <div className="date-range-options">
              <label>
                <input
                  type="radio"
                  value="daily"
                  checked={dateRangeType === 'daily'}
                  onChange={() => setDateRangeType('daily')}
                />
                Daily
              </label>
              <label>
                <input
                  type="radio"
                  value="weekly"
                  checked={dateRangeType === 'weekly'}
                  onChange={() => setDateRangeType('weekly')}
                />
                Weekly
              </label>
              <label>
                <input
                  type="radio"
                  value="monthly"
                  checked={dateRangeType === 'monthly'}
                  onChange={() => setDateRangeType('monthly')}
                />
                Monthly
              </label>
            </div>
            <button className="btn primary" onClick={handleCalculate}>Apply Filter</button>
          </div>
        </div>
        <div className="stats">
          <div className="stat">
            <h5>Peek Load</h5>
            <p>{peekLoad}%</p>
          </div>
          <div className="stat">
            <h5>Min Load</h5>
            <p>{minLoad}%</p>
          </div>
          <div className="stat">
            <h5>Cost Incurred</h5>
            <p>${costIncurred.toFixed(2)}</p>
          </div>
        </div>
      </div>

      <ResponsiveContainer width="100%" height={400}>
        <LineChart data={data} margin={{ top: 20, right: 30, left: 20, bottom: 10 }}>
          <CartesianGrid stroke="#f5f5f5" />
          <XAxis dataKey="name" />
          <YAxis label={{ value: 'Usage (%)', angle: -90, position: 'insideLeft' }} />
          <Tooltip contentStyle={{ backgroundColor: '#fff', border: '1px solid #ccc' }} />
          <Legend verticalAlign="top" height={36} />
          <Line type="monotone" dataKey="usage" stroke="#1890ff" activeDot={{ r: 8 }} name={null} />
          <Brush dataKey="name" height={30} stroke="#1890ff" />
        </LineChart>
      </ResponsiveContainer>

      <div className="footer">
        <div className="savings">
          <h5>Potential Savings</h5>
          <p>${potentialSavings.toFixed(2)}</p>
        </div>
        <div className="buttons">
          <CSVLink data={exportData} filename={"app-usage-data.csv"} className="btn secondary">
            Export Data
          </CSVLink>
          
          <Link to="/policy" className="btn primary">Apply Policy</Link>
        </div>
      </div>
    </div>
  );
};

export default AppOverview;
body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background-color: #f4f6f9;
    color: #333;
    margin: 0;
    padding: 0;
  }
  
  .app-overview {
    margin: 20px;
    padding: 20px;
    background-color: white;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    border-radius: 10px;
  }
  
  .header, .footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 10px 0;
    border-bottom: 1px solid #e0e0e0;
  }
  
  .footer {
    border-top: 1px solid #e0e0e0;
    border-bottom: none;
    margin-top: 20px;
    padding-top: 20px;
  }
  
  .app-info {
    display: flex;
    flex-direction: column;
    gap: 10px;
  }
  
  .date-picker {
    display: flex;
    gap: 10px;
    margin-top: 10px;
  }
  
  .stats {
    display: flex;
    gap: 20px;
  }
  
  .stat {
    display: flex;
    flex-direction: column;
    align-items: center;
    background-color: #f8f9fa;
    padding: 10px 20px;
    border-radius: 10px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  }
  
  .stat h5 {
    margin: 0;
    font-size: 1em;
    color: #666;
  }
  
  .stat p {
    margin: 0;
    font-size: 1.2em;
    font-weight: bold;
    color: #333;
  }
  
  .savings {
    background-color: #dff0d8;
    padding: 10px;
    border-radius: 10px;
    display: flex;
    flex-direction: column;
    align-items: center;
  }
  
  .savings h5 {
    margin: 0;
    font-size: 1em;
    color: #3c763d;
  }
  
  .savings p {
    margin: 0;
    font-size: 1.2em;
    font-weight: bold;
    color: #3c763d;
  }
  
  .buttons {
    display: flex;
    gap: 10px;
  }
  
  .btn {
    padding: 10px 20px;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    transition: background-color 0.3s ease;
  }
  
  .primary {
    background-color: #007bff;
    color: white;
  }
  
  .primary:hover {
    background-color: #0056b3;
  }
  
  .secondary {
    background-color: #6c757d;
    color: white;
  }
  
  .secondary:hover {
    background-color: #5a6268;
  }
  
  .prediction {
    margin-top: 20px;
  }
  
  .prediction h3 {
    text-align: center;
  }
  
  .modal, .recommendation {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
  }
  
  .modal-content, .recommendation-content {
    background: white;
    padding: 20px;
    border-radius: 10px;
    max-width: 500px;
    width: 100%;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    position: relative;
  }
  
  .close {
    position: absolute;
    top: 10px;
    right: 10px;
    cursor: pointer;
  }
  
  .modal-footer {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    margin-top: 20px;
  }
  import json
import random
from datetime import datetime, timedelta

# Generate 100 days of mock data
start_date = datetime.now().date() - timedelta(days=100)
data = []
for i in range(100):
    date = (start_date + timedelta(days=i)).strftime('%Y-%m-%d')
    usage = random.randint(10, 100)  # Random usage between 10 and 100 (modify as needed)
    data.append({'name': date, 'usage': usage})

# Save data to JSON file
with open('data.json', 'w') as f:
    json.dump(data, f)
data = []
for i in range(100):
    date = (start_date + timedelta(days=i)).strftime('%Y-%m-%d')
    usage = random.randint(10, 100)  # Random usage between 10 and 100 (modify as needed)
    data.append({'name': date, 'usage': usage})

# Save data to JSON file
with open('data2.json', 'w') as f:
    json.dump(data, f)
print("Data saved to data.json")
