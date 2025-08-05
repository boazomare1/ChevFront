# Today Summary API Guide for Backend Developer

This guide provides the API specification for implementing the "Today Summary" endpoint that will provide sales data for the today_summary screen.

## Current API Pattern Analysis

Based on the existing API endpoints, here's the pattern your backend should follow:

### Base URL Pattern
```
https://chevenergies.techsavanna.technology/api/method/route_plan.apis.sales.[endpoint_name]
```

### Authentication
- **Method**: Bearer Token
- **Header**: `Authorization: Bearer {token}`
- **Content-Type**: `application/json`

## New Endpoint: Today Summary

### Endpoint Details
- **URL**: `route_plan.apis.sales.get_today_summary`
- **Method**: POST
- **Authentication**: Required (Bearer Token)

### Request Parameters

```json
{
  "route_id": "KDC 378L",
  "day": "monday",
  "date": "2024-01-15"
}
```

### Parameters Explanation

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `route_id` | string | Yes | The salesperson's route ID (e.g., "KDC 378L") |
| `day` | string | Yes | Day of the week (lowercase: "monday", "tuesday", etc.) |
| `date` | string | Yes | Date in YYYY-MM-DD format |

### Expected Response Structure

```json
{
  "status": 200,
  "message": "Today summary retrieved successfully",
  "data": {
    "salesperson_info": {
      "route_id": "KDC 378L",
      "name": "BENARD KEVA",
      "employee_id": "EMP010"
    },
    "date_info": {
      "day": "monday",
      "date": "2024-01-15",
      "formatted_date": "Monday, January 15, 2024"
    },
    "sales_summary": {
      "total_sales_amount": 70900,
      "total_sales_currency": "KES",
      "formatted_total": "KES 70,900",
      "standard_sales_count": 22,
      "discounted_sales_count": 0,
      "ticket_sales_count": 40,
      "total_customers": 58,
      "customers_served": 58,
      "customers_pending": 0
    },
    "sales_items": [
      {
        "item_id": "4081",
        "item_name": "POWER GAS 6KG CYLINDER",
        "quantity": 3,
        "unit_price": 1550,
        "total_price": 4650,
        "formatted_total": "4,650"
      },
      {
        "item_id": "4096",
        "item_name": "POWER GAS 13KG CYLINDER",
        "quantity": 2,
        "unit_price": 1325,
        "total_price": 2650,
        "formatted_total": "2,650"
      },
      {
        "item_id": "4099",
        "item_name": "POWER REFIL 6KG",
        "quantity": 52,
        "unit_price": 900,
        "total_price": 46800,
        "formatted_total": "46,800"
      },
      {
        "item_id": "4100",
        "item_name": "POWER REFIL 13KG",
        "quantity": 4,
        "unit_price": 1950,
        "total_price": 7800,
        "formatted_total": "7,800"
      },
      {
        "item_id": "4108",
        "item_name": "POWER REFIL 50KG",
        "quantity": 1,
        "unit_price": 7500,
        "total_price": 7500,
        "formatted_total": "7,500"
      },
      {
        "item_id": "4120",
        "item_name": "#A1 burners",
        "quantity": 5,
        "unit_price": 300,
        "total_price": 1500,
        "formatted_total": "1,500"
      }
    ],
    "sales_statistics": {
      "total_invoices": 62,
      "paid_invoices": 62,
      "pending_invoices": 0,
      "cash_payments": 45,
      "mobile_money_payments": 12,
      "bank_transfer_payments": 5
    }
  }
}
```

### Error Response Examples

#### 1. Invalid Route ID
```json
{
  "status": 404,
  "message": "Route not found",
  "data": {}
}
```

#### 2. No Sales Data for Date
```json
{
  "status": 200,
  "message": "No sales data found for the specified date",
  "data": {
    "salesperson_info": {
      "route_id": "KDC 378L",
      "name": "BENARD KEVA",
      "employee_id": "EMP010"
    },
    "date_info": {
      "day": "monday",
      "date": "2024-01-15",
      "formatted_date": "Monday, January 15, 2024"
    },
    "sales_summary": {
      "total_sales_amount": 0,
      "total_sales_currency": "KES",
      "formatted_total": "KES 0",
      "standard_sales_count": 0,
      "discounted_sales_count": 0,
      "ticket_sales_count": 0,
      "total_customers": 0,
      "customers_served": 0,
      "customers_pending": 0
    },
    "sales_items": [],
    "sales_statistics": {
      "total_invoices": 0,
      "paid_invoices": 0,
      "pending_invoices": 0,
      "cash_payments": 0,
      "mobile_money_payments": 0,
      "bank_transfer_payments": 0
    }
  }
}
```

#### 3. Authentication Error
```json
{
  "status": 401,
  "message": "Authentication failed",
  "data": {}
}
```

## Frappe Implementation Guide

### 1. Create the API Method

Create a new file: `route_plan/apis/sales.py` (or add to existing)

```python
import frappe
from frappe import _
from datetime import datetime
import json

@frappe.whitelist()
def get_today_summary():
    """Get today's sales summary for a specific route"""
    
    # Get request data
    data = frappe.request.get_json()
    route_id = data.get('route_id')
    day = data.get('day')
    date = data.get('date')
    
    # Validate required fields
    if not route_id or not day or not date:
        frappe.throw("Missing required parameters: route_id, day, date")
    
    try:
        # Parse date
        date_obj = datetime.strptime(date, '%Y-%m-%d')
        
        # Get salesperson info
        salesperson_info = get_salesperson_info(route_id)
        
        # Get sales data for the date
        sales_data = get_sales_data(route_id, date)
        
        # Calculate summary statistics
        summary = calculate_summary(sales_data)
        
        # Format response
        response = {
            "status": 200,
            "message": "Today summary retrieved successfully",
            "data": {
                "salesperson_info": salesperson_info,
                "date_info": {
                    "day": day,
                    "date": date,
                    "formatted_date": date_obj.strftime("%A, %B %d, %Y")
                },
                "sales_summary": summary,
                "sales_items": sales_data.get('items', []),
                "sales_statistics": sales_data.get('statistics', {})
            }
        }
        
        return response
        
    except Exception as e:
        frappe.log_error(f"Today Summary API Error: {str(e)}")
        return {
            "status": 500,
            "message": f"Internal server error: {str(e)}",
            "data": {}
        }

def get_salesperson_info(route_id):
    """Get salesperson information by route ID"""
    # Query your salesperson/route table
    # Example: frappe.get_doc("Salesperson", {"route_id": route_id})
    return {
        "route_id": route_id,
        "name": "BENARD KEVA",  # Get from database
        "employee_id": "EMP010"  # Get from database
    }

def get_sales_data(route_id, date):
    """Get sales data for the specified route and date"""
    # Query your sales/invoice tables
    # This is where you'll aggregate the actual sales data
    
    # Example query structure:
    # invoices = frappe.get_all("Sales Invoice", 
    #     filters={
    #         "route_id": route_id,
    #         "posting_date": date,
    #         "docstatus": 1  # Submitted invoices
    #     },
    #     fields=["name", "total", "payment_status", "payment_method"]
    # )
    
    # For now, returning mock data structure
    return {
        "items": [
            {
                "item_id": "4081",
                "item_name": "POWER GAS 6KG CYLINDER",
                "quantity": 3,
                "unit_price": 1550,
                "total_price": 4650,
                "formatted_total": "4,650"
            }
            # ... more items
        ],
        "statistics": {
            "total_invoices": 62,
            "paid_invoices": 62,
            "pending_invoices": 0,
            "cash_payments": 45,
            "mobile_money_payments": 12,
            "bank_transfer_payments": 5
        }
    }

def calculate_summary(sales_data):
    """Calculate summary statistics from sales data"""
    items = sales_data.get('items', [])
    statistics = sales_data.get('statistics', {})
    
    total_amount = sum(item.get('total_price', 0) for item in items)
    
    return {
        "total_sales_amount": total_amount,
        "total_sales_currency": "KES",
        "formatted_total": f"KES {total_amount:,}",
        "standard_sales_count": statistics.get('total_invoices', 0),
        "discounted_sales_count": 0,  # Calculate from discount sales
        "ticket_sales_count": 0,  # Calculate from ticket sales
        "total_customers": statistics.get('total_invoices', 0),
        "customers_served": statistics.get('paid_invoices', 0),
        "customers_pending": statistics.get('pending_invoices', 0)
    }
```

### 2. Database Schema Requirements

Your Frappe app should have these tables (or equivalent):

#### Sales Invoice Table
```sql
-- Example structure
CREATE TABLE `tabSales Invoice` (
    `name` varchar(255) PRIMARY KEY,
    `route_id` varchar(255),
    `salesperson_id` varchar(255),
    `posting_date` date,
    `total` decimal(10,2),
    `payment_status` varchar(50),
    `payment_method` varchar(50),
    `docstatus` int(1)
);
```

#### Sales Invoice Items Table
```sql
-- Example structure
CREATE TABLE `tabSales Invoice Item` (
    `name` varchar(255) PRIMARY KEY,
    `parent` varchar(255),  -- References Sales Invoice
    `item_id` varchar(255),
    `item_name` varchar(255),
    `qty` int,
    `rate` decimal(10,2),
    `amount` decimal(10,2)
);
```

#### Route/Salesperson Table
```sql
-- Example structure
CREATE TABLE `tabSalesperson` (
    `name` varchar(255) PRIMARY KEY,
    `route_id` varchar(255),
    `employee_id` varchar(255),
    `full_name` varchar(255)
);
```

### 3. Testing the API

#### Test Request
```bash
curl -X POST \
  https://chevenergies.techsavanna.technology/api/method/route_plan.apis.sales.get_today_summary \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer YOUR_TOKEN_HERE' \
  -d '{
    "route_id": "KDC 378L",
    "day": "monday",
    "date": "2024-01-15"
  }'
```

#### Test Response Validation
- Status code should be 200
- Response should contain all required fields
- Numbers should be properly formatted
- Currency should be in KES
- Dates should be in correct format

## Integration with Flutter App

Once the API is ready, the Flutter app will:

1. **Call the API** with route_id, day, and date
2. **Display the data** in the today_summary screen
3. **Handle errors** gracefully
4. **Format numbers** according to the response

## Key Points for Implementation

1. **Follow existing API patterns** - Use the same structure as other endpoints
2. **Handle authentication** - Validate Bearer token
3. **Validate input** - Check for required parameters
4. **Format numbers** - Use proper thousand separators
5. **Handle empty data** - Return zero values when no sales exist
6. **Error handling** - Provide meaningful error messages
7. **Performance** - Optimize database queries for large datasets

## Questions for Backend Developer

1. What are your actual table names for sales data?
2. How do you store route information?
3. What payment methods do you support?
4. How do you distinguish between standard sales, discounted sales, and ticket sales?
5. What's your preferred date format for queries?
6. Do you have any existing aggregation functions for sales data?

This API will enable the Flutter app to display comprehensive sales summaries for any salesperson on any given day. 