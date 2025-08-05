# Sample API Responses for User Authentication

This document contains sample API responses for different user types to help determine dashboard routing.

## 1. Sales Person / Field Agent Response

```json
{
  "status": 200,
  "message": "Login successful",
  "data": {
    "user": {
      "email": "salesperson@chevenergies.com",
      "name": "John Doe",
      "employee": "EMP001",
      "sales_person": "SP001",
      "first_name": "John",
      "last_name": "Doe",
      "role": ["sales_person", "field_agent"],
      "route": [
        {
          "route_id": "ROUTE001",
          "vehicle": "KCA 123A",
          "warehouse": "WH001",
          "warehouse_name": "Nairobi Central Warehouse"
        }
      ]
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

## 2. Stock Taker / Store Keeper Response

```json
{
  "status": 200,
  "message": "Login successful",
  "data": {
    "user": {
      "email": "stockkeeper@chevenergies.com",
      "name": "Jane Smith",
      "employee": "EMP002",
      "sales_person": null,
      "first_name": "Jane",
      "last_name": "Smith",
      "role": ["stock_keeper", "store_keeper"],
      "route": []
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

## 3. Warehouse Manager Response

```json
{
  "status": 200,
  "message": "Login successful",
  "data": {
    "user": {
      "email": "warehouse@chevenergies.com",
      "name": "Mike Johnson",
      "employee": "EMP003",
      "sales_person": null,
      "first_name": "Mike",
      "last_name": "Johnson",
      "role": ["warehouse_manager", "stock_keeper"],
      "route": [
        {
          "route_id": "WH001",
          "vehicle": null,
          "warehouse": "WH001",
          "warehouse_name": "Nairobi Central Warehouse"
        }
      ]
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

## 4. Admin / Manager Response

```json
{
  "status": 200,
  "message": "Login successful",
  "data": {
    "user": {
      "email": "admin@chevenergies.com",
      "name": "Admin User",
      "employee": "EMP004",
      "sales_person": null,
      "first_name": "Admin",
      "last_name": "User",
      "role": ["admin", "manager"],
      "route": []
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

## 5. Multi-Role User Response

```json
{
  "status": 200,
  "message": "Login successful",
  "data": {
    "user": {
      "email": "supervisor@chevenergies.com",
      "name": "Sarah Wilson",
      "employee": "EMP005",
      "sales_person": "SP002",
      "first_name": "Sarah",
      "last_name": "Wilson",
      "role": ["sales_person", "stock_keeper", "supervisor"],
      "route": [
        {
          "route_id": "ROUTE002",
          "vehicle": "KCB 456B",
          "warehouse": "WH002",
          "warehouse_name": "Mombasa Warehouse"
        }
      ]
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

## 6. Error Response (Invalid Credentials)

```json
{
  "status": 401,
  "message": "Login failed. Invalid credentials.",
  "data": {}
}
```

## 7. Error Response (Account Disabled)

```json
{
  "status": 403,
  "message": "Account is disabled. Please contact administrator.",
  "data": {}
}
```

## Dashboard Routing Logic

Based on the user roles, here's how the app should route users:

### Role-Based Dashboard Assignment:

1. **`["sales_person"]`** → **Main Dashboard** (Sales, Customers, Routes)
2. **`["stock_keeper"]`** → **Stock Keeper Dashboard** (Stock Management, Salespeople)
3. **`["warehouse_manager"]`** → **Stock Keeper Dashboard** (with warehouse access)
4. **`["admin"]`** → **Admin Dashboard** (Full access)
5. **`["supervisor"]`** → **Supervisor Dashboard** (Multi-role access)

### Implementation Notes:

- **Primary Role**: Use the first role in the array for main dashboard routing
- **Secondary Roles**: Use for feature access within dashboards
- **Empty Routes**: Stock keepers typically don't have assigned routes
- **Warehouse Access**: Warehouse managers have warehouse info instead of vehicle routes

### Backend Requirements:

1. **Create stock keeper user** with role `["stock_keeper"]`
2. **No assigned routes** for stock keepers
3. **Include employee ID** for tracking
4. **Set sales_person to null** for non-sales roles
5. **Provide proper JWT token** for authentication

### Testing Credentials:

```
Email: stockkeeper@chevenergies.com
Password: [your-secure-password]
Role: stock_keeper
```

This will automatically route to the Stock Keeper Dashboard when the backend is ready. 