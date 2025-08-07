# 📍 Stop Info API Update - Add Missing Fields

## Overview
The frontend currently defaults `latitude` and `longitude` fields in the `stop_info` object when they are missing. To provide accurate location data for the Resale feature, these fields need to be added to the backend API response.

## 🔧 Current Frontend Defaults

When `stop_info` is missing `latitude` and `longitude`, the frontend currently defaults to:
```json
{
  "latitude": -1.263049,
  "longitude": 36.803552
}
```

These coordinates represent **Nairobi, Kenya** (approximately the city center).

## 📋 Required API Changes

### 1. Update Stop Info Response Structure

**Current Response:**
```json
{
  "stop_info": {
    "stop_id": "STOP123",
    "route_id": "ROUTE456", 
    "served_date": "2025-01-20"
  }
}
```

**Updated Response:**
```json
{
  "stop_info": {
    "stop_id": "STOP123",
    "route_id": "ROUTE456",
    "served_date": "2025-01-20",
    "latitude": -1.263049,
    "longitude": 36.803552
  }
}
```

### 2. Field Specifications

| Field | Type | Required | Description | Example |
|-------|------|----------|-------------|---------|
| `latitude` | `number` | ✅ Yes | Decimal degrees (negative for South) | `-1.263049` |
| `longitude` | `number` | ✅ Yes | Decimal degrees (positive for East) | `36.803552` |

### 3. Coordinate System
- **Format**: Decimal degrees (WGS84)
- **Precision**: 6 decimal places recommended
- **Range**: 
  - Latitude: -90 to +90
  - Longitude: -180 to +180

## 🎯 Use Case: Resale Feature

These coordinates are used in the **Resale feature** to:
1. **Direct Navigation**: When a user clicks "Make Sale" on today's sales history
2. **Location Accuracy**: Provide exact shop location for salespeople
3. **Distance Calculation**: Enable accurate distance calculations from current location

## 🔄 Implementation Steps

### Backend Changes Required:

1. **Database Schema Update:**
   ```sql
   ALTER TABLE stops ADD COLUMN latitude DECIMAL(10, 8);
   ALTER TABLE stops ADD COLUMN longitude DECIMAL(11, 8);
   ```

2. **API Response Update:**
   - Modify the endpoint that returns invoice/sale data
   - Include `latitude` and `longitude` in the `stop_info` object
   - Ensure these fields are populated when creating/updating stops

3. **Data Migration:**
   - Update existing stop records with actual coordinates
   - For stops without coordinates, use the default Nairobi coordinates

### Frontend Changes:
- ✅ **Already implemented** - Frontend handles missing coordinates gracefully
- ✅ **Default fallback** - Uses Nairobi coordinates when fields are null/missing
- ✅ **No breaking changes** - Existing functionality continues to work

## 📊 Example API Response

**Complete Invoice Response with Stop Info:**
```json
{
  "status": 200,
  "message": "Invoice retrieved successfully",
  "data": {
    "invoice_id": "ACC-SINV-2025-00070",
    "customer_name": "ABC Mart",
    "total_amount": 21980.00,
    "payment_status": "Paid",
    "created_date": "2025-01-20",
    "stop_info": {
      "stop_id": "STOP123",
      "route_id": "ROUTE456",
      "served_date": "2025-01-20",
      "latitude": -1.263049,
      "longitude": 36.803552
    }
  }
}
```

## 🧪 Testing

### Test Cases:
1. **With Coordinates**: Verify coordinates are used for navigation
2. **Without Coordinates**: Verify default Nairobi coordinates are used
3. **Null Values**: Verify graceful handling of null latitude/longitude
4. **Invalid Coordinates**: Verify validation and fallback behavior

### Expected Behavior:
- **Resale Button**: Only shows for today's sales
- **Navigation**: Uses actual coordinates when available
- **Fallback**: Uses default coordinates when missing
- **Distance Calc**: Accurate distance calculations for salespeople

## 📞 Contact
For any questions about the coordinate system or implementation details, please contact the frontend development team.

---

**Priority**: Medium  
**Impact**: Improves location accuracy for Resale feature  
**Breaking Changes**: None (frontend already handles missing fields) 