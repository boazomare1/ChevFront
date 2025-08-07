# 📋 Stock Keeper API Specifications

## Overview
This document outlines the API endpoints needed for the Stock Keeper module in the Chev Energies mobile app. The Stock Keeper needs to:
1. **List all vehicles/salespeople** for inventory management
2. **Get stock items** for a specific route/vehicle
3. **Submit inventory counts** with variance calculations

---

## 🚗 1. List Vehicles/Salespeople

### Endpoint
```
GET /route_plan.apis.stock.list_vehicles
```

### Headers
```json
{
  "Content-Type": "application/json",
  "Authorization": "Bearer {token}"
}
```

### Expected Response
```json
{
  "status": 200,
  "message": "Vehicles retrieved successfully",
  "data": [
    {
      "name": "VINCENT ATEMA",
      "code": "KDS 082M",
      "phone": "+254 712 345 678",
      "region": "Nairobi Central",
      "vehicle": "KCA 123A"
    },
    {
      "name": "JOHN SIMIYU",
      "code": "KDA 159Z",
      "phone": "+254 723 456 789",
      "region": "Mombasa Coast",
      "vehicle": "KCB 456B"
    }
  ]
}
```

### Error Response
```json
{
  "status": 400,
  "message": "Failed to retrieve vehicles",
  "error": "Invalid token or insufficient permissions"
}
```

---

## 📦 2. Get Stock Items for Route

### Endpoint
```
GET /route_plan.apis.stock.get_vehicle_items?route_id={route_id}
```

### Headers
```json
{
  "Content-Type": "application/json",
  "Authorization": "Bearer {token}"
}
```

### Expected Response
```json
{
  "status": 200,
  "message": "Vehicle items retrieved successfully",
  "data": [
    {
      "id": "4103",
      "name": "POWER REFIL 13KG",
      "system_quantity": 50,
      "unit": "Nos"
    },
    {
      "id": "4104",
      "name": "lantern",
      "system_quantity": 25,
      "unit": "Nos"
    },
    {
      "id": "4105",
      "name": "GLASS TOP 2 BURNER",
      "system_quantity": 15,
      "unit": "Nos"
    }
  ]
}
```

### Error Response
```json
{
  "status": 400,
  "message": "Failed to fetch vehicle items",
  "error": "Invalid route_id"
}
```

---

## 📤 3. Submit Stock Count

### Endpoint
```
POST /route_plan.apis.stock.submit_count
```

### Headers
```json
{
  "Content-Type": "application/json",
  "Authorization": "Bearer {token}"
}
```

### Request Payload
```json
{
  "route_id": "KDS 082M",
  "salesperson_name": "VINCENT ATEMA",
  "count_date": "2025-01-20",
  "counted_by": "stock_keeper@email.com",
  "items": [
    {
      "item_id": "4103",
      "item_name": "POWER REFIL 13KG",
      "system_quantity": 50,
      "physical_quantity": 48,
      "variance": -2
    },
    {
      "item_id": "4104",
      "item_name": "lantern",
      "system_quantity": 25,
      "physical_quantity": 25,
      "variance": 0
    },
    {
      "item_id": "4105",
      "item_name": "GLASS TOP 2 BURNER",
      "system_quantity": 15,
      "physical_quantity": 16,
      "variance": 1
    }
  ],
  "total_items_counted": 3,
  "total_variance": -1
}
```

### Success Response
```json
{
  "status": 200,
  "message": "Stock count submitted successfully",
  "data": {
    "count_id": "COUNT-2025-001",
    "route_id": "KDS 082M",
    "salesperson_name": "VINCENT ATEMA",
    "count_date": "2025-01-20",
    "submitted_at": "2025-01-20T14:30:00Z",
    "total_items_counted": 3,
    "total_variance": -1,
    "status": "Submitted"
  }
}
```

### Error Response
```json
{
  "status": 400,
  "message": "Failed to submit stock count",
  "error": "Invalid route_id or missing required fields"
}
```

---

## 🔧 Implementation Notes

### Key Points:
1. **Use `route_id` not `vehicle_id`** - All endpoints use route_id as the identifier
2. **Variance Calculation** - Variance = physical_quantity - system_quantity
3. **Date Format** - Use YYYY-MM-DD format for dates
4. **Authentication** - All endpoints require Bearer token authentication

### User Flow:
1. Stock Keeper opens "Salespeople" screen → Calls `list_vehicles`
2. Clicks "Next" on a vehicle → Calls `get_vehicle_items` with route_id
3. Enters physical quantities → Calls `submit_count` with complete payload
4. Shows success/error message based on API response

### Current Status:
- ✅ Frontend implementation is complete
- ✅ API integration is ready
- ⏳ Backend endpoints need to be implemented
- ⏳ Once backend is ready, app will switch from simulation to real API calls

### Testing:
- The app currently shows mock data
- Once these endpoints are implemented, the app will automatically use real data
- No frontend changes needed after backend implementation

---

## 📞 Contact
For any questions about the API specifications, please contact the frontend development team. 