# Chev Energies - LPG Sales Management System

A comprehensive Flutter application for managing LPG cylinder sales, accessories, and customer relationships. Built for salespeople and stock keepers to efficiently handle their daily operations in the gas distribution business.

## 📱 Features

### 🔐 Authentication & Security
- **Email/Password Login**: Traditional authentication method
- **Fingerprint Authentication**: Quick and secure biometric login
- **Remember Me**: Option to save credentials for faster access
- **Role-based Access**: Different dashboards for salespeople and stock keepers

### 🏠 Dashboard
- **Main Dashboard**: Overview of routes, today's activities, and total statistics
- **Stock Keeper Dashboard**: Specialized interface for inventory management
- **Quick Actions**: Easy access to all major functions
- **Recent Activity**: Track recent sales and operations

### 💰 Sales Management
- **Make Sales**: Create new LPG cylinder sales transactions
- **Sales History**: View and search past gas sales
- **Sales Dashboard**: Analytics and summary reports
- **Discount Sales**: Handle discounted cylinder transactions
- **Cheque Sales**: Process cheque-based payments
- **Payment Processing**: Handle various payment methods

### 📦 Inventory Management
- **Current Stock**: View and manage available gas cylinders and accessories
- **Stock Management**: Comprehensive LPG inventory management interface
- **Stock Reports**: Generate cylinder inventory reports and analytics
- **Stock Updates**: Real-time gas cylinder tracking
- **Add Items**: Add new cylinders and accessories with detailed forms
- **Stock Transfer**: Transfer cylinders between locations
- **Stock Analytics**: Advanced LPG inventory analytics and insights

### 👥 Customer Management
- **Customer Database**: Manage customer information
- **Add Customers**: Register new customers
- **Customer Routes**: Organize customers by routes
- **Customer Search**: Quick customer lookup

### 📊 Financial Management
- **Expenditure Tracking**: Record and monitor expenses
- **Expenditure Details**: Detailed expense reports
- **Financial Reports**: Generate financial summaries
- **Invoice Management**: Create and manage invoices

### 🛠️ Additional Features
- **Profile Management**: Update user information and profile image
- **Password Management**: Change account password securely
- **Settings**: Configure app preferences and user preferences
- **Biometric Settings**: Manage fingerprint authentication
- **Offline Support**: Work without internet connection
- **Data Export**: Export reports in various formats
- **Stock Analytics**: Advanced inventory analytics and reporting
- **Multi-location Support**: Manage inventory across multiple locations
- **Supplier Management**: Track suppliers and manage relationships
- **Category Management**: Organize inventory by categories
- **Dark Mode**: Complete dark theme support with automatic switching

## 🚀 Installation

### Prerequisites
- Flutter SDK (3.7.2 or higher)
- Dart SDK
- Android Studio / VS Code
- Android device or emulator (API level 21+)

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd chevenergies
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Android permissions**
   The app requires the following permissions (already configured):
   - Location access (for route management)
   - Camera access (for document scanning)
   - Storage access (for file operations)
   - Biometric access (for fingerprint authentication)

4. **Run the application**
   ```bash
   flutter run
   ```

### Building for Production

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

## 📋 How to Access Features

### 🔐 Login & Authentication

1. **First Time Setup**:
   - Enter your email and password
   - Check "Remember Me" to enable fingerprint authentication
   - Tap "SIGN IN"

2. **Fingerprint Login** (after setup):
   - Tap "Login with Fingerprint" on the login screen
   - Use your device's fingerprint sensor
   - Access biometric settings from dashboard drawer

### 🏠 Dashboard Navigation

**Main Dashboard** (Salespeople):
- Access via login → Main dashboard
- Quick actions grid for common tasks
- Recent activity feed
- Route statistics

**Stock Keeper Dashboard**:
- Access via login → Stock keeper dashboard
- Inventory management tools
- Stock reports and analytics
- Salespeople management

### 💰 Sales Operations

**Make a Sale**:
1. Dashboard → "Make Sale" button
2. Select customer from route
3. Add items to cart
4. Apply discounts if needed
5. Process payment
6. Generate invoice

**View Sales History**:
1. Dashboard → "Sales History" button
2. Filter by date range
3. Search specific transactions
4. View detailed invoice information

**Sales Dashboard**:
1. Dashboard → "Sales Dashboard" button
2. View sales analytics
3. Generate summary reports
4. Export data

**Discount Sales**:
1. Dashboard → "Discount Sales" button
2. Create discounted transactions
3. Apply percentage or fixed discounts
4. Track discount history

**Cheque Sales**:
1. Dashboard → "Cheque Sales" button
2. Process cheque payments
3. Record cheque details
4. Track payment status

### 📦 Inventory Management

**View Current Stock**:
1. Dashboard → "Stock" button
2. View available inventory
3. Check stock levels
4. Filter by categories

**Stock Management** (Stock Keepers):
1. Stock Keeper Dashboard → "Stock Management"
2. View all inventory items with search and filtering
3. Check stock levels and status
4. Monitor item categories and locations
5. Track stock movements and updates

**Stock Reports**:
1. Stock Keeper Dashboard → "Stock Reports"
2. View comprehensive inventory analytics
3. Monitor key metrics (total value, items, categories)
4. Track top items by value
5. Analyze category breakdown with visual charts
6. Export stock data and reports

**Add New Items**:
1. Stock Keeper Dashboard → "Add Items" (Quick Actions)
2. Fill detailed item information (name, category, price)
3. Set initial quantity and unit
4. Specify storage location and supplier
5. Add optional description and notes
6. Auto-generate item IDs based on category

**Stock Transfer**:
1. Stock Keeper Dashboard → "Stock Transfer" (Quick Actions)
2. Select item to transfer from available inventory
3. Choose source and destination locations
4. Specify transfer quantity
5. Add transfer notes
6. Validate transfer requirements
7. Initiate transfer process

### 👥 Customer Management

**View Customers**:
1. Dashboard → "Customers" button
2. Browse customer list by route
3. Search specific customers
4. View customer details

**Add New Customer**:
1. Customers screen → "Add Customer" button
2. Fill customer information
3. Assign to route
4. Save customer data

**Customer Details**:
1. Customer list → Tap customer name
2. View customer information
3. Check purchase history
4. Update customer data

### 📊 Financial Management

**Record Expenditure**:
1. Dashboard → "Expenditures" button
2. Tap "Add Expense" button
3. Fill expense details
4. Attach receipts (optional)
5. Save expense record

**View Expenditure Details**:
1. Expenditure list → Tap expense item
2. View detailed information
3. Check receipt images
4. Edit if needed

**Financial Reports**:
1. Dashboard → "Sales Dashboard"
2. Generate financial summaries
3. Export reports
4. View analytics

### 🛠️ Settings & Profile

**Profile Management**:
1. Dashboard drawer → "Profile"
2. Update personal information
3. Change profile picture
4. Update contact details

**Dark Mode Usage**:
1. **Enable Dark Mode**: Settings → Toggle "Dark Mode" switch
2. **Automatic Switching**: Theme changes instantly across all screens
3. **Persistent Settings**: Your preference is saved and restored
4. **System Integration**: Follows Material Design 3 guidelines
5. **Accessibility**: Better visibility in low-light conditions

**Fingerprint Settings**:
1. Dashboard drawer → "Fingerprint Settings"
2. Enable/disable fingerprint authentication
3. Test fingerprint functionality
4. View device compatibility

**Change Password**:
1. Dashboard drawer → "Change Password"
2. Enter current password
3. Set new password (minimum 6 characters)
4. Confirm new password
5. Submit changes

 **Update Profile Image**:
 1. Dashboard drawer → "Update Profile Image"
 2. Select image from camera or gallery
 3. Preview the selected image
 4. Submit to update profile picture

### 📱 App Navigation

**Drawer Menu** (Main Dashboard):
- Profile
- Change Password
- Update Profile Image
- Fingerprint Settings
- Logout

**Drawer Menu** (Stock Keeper Dashboard):
- Dashboard
- Salespeople
- Stock Management
- Stock Reports
- Settings
- Fingerprint Settings
- Logout

**Quick Actions Grid** (Main Dashboard):
- Make Sale
- Stock
- Expenditures
- Customers
- Sales History
- Sales Dashboard
- Discount Sales
- Cheque Sales

**Quick Actions Grid** (Stock Keeper Dashboard):
- Salespeople
- Stock Count
- Stock Reports
- Add Items
- Stock Transfer
- Settings
- Dark Mode Toggle

## 🔧 Technical Details

### Architecture
- **Framework**: Flutter 3.7.2+
- **State Management**: Provider pattern
- **Local Storage**: SharedPreferences
- **Biometric Auth**: local_auth package

- **HTTP Client**: http package
- **File Operations**: path_provider, share_plus

### Key Dependencies
```yaml
dependencies:
  flutter: sdk: flutter
  provider: ^6.1.2
  local_auth: ^2.1.8
  shared_preferences: ^2.2.2
  http: ^1.2.2
  geolocator: ^9.0.2
  image_picker: ^0.8.4+3

  pdf: ^3.10.4
  printing: ^5.12.0
  excel: ^4.0.6
  share_plus: ^10.0.3
```

### File Structure
```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
├── screens/                  # UI screens
├── services/                 # Business logic
├── shared utils/             # Shared components
└── forms/                    # Form components
```

## 🚨 Troubleshooting

### Common Issues

**Login Problems**:
- Check internet connection
- Verify email/password
- Try fingerprint login if enabled
- Contact administrator for account issues

**Fingerprint Not Working**:
- Ensure device has fingerprint sensor
- Check device fingerprint settings
- Re-register fingerprint in device settings
- Verify "Remember Me" was enabled during first login

**App Crashes**:
- Clear app cache
- Restart the application
- Check device storage space
- Update to latest version

**Data Not Syncing**:
- Check internet connection
- Refresh the screen
- Logout and login again
- Contact support if persistent



### Error Messages

- **"Authentication Failed"**: Check credentials and try again
- **"No stored credentials found"**: Login manually with "Remember Me" checked
- **"Biometric authentication failed"**: Check device fingerprint settings
- **"Network error"**: Check internet connection and try again


## 📞 Support

For technical support or questions:
- Check the troubleshooting section above
- Review the app's help documentation
- Contact the development team
- Report bugs through the app's feedback system

## 📄 License

This application is proprietary software developed for Chev Energies. All rights reserved.

## 🔄 Version History

- **v1.0.0**: Initial release with core features
- Added fingerprint authentication
- Enhanced sales management
- Improved inventory tracking
- Better user experience

### Recent Updates

**Dark Mode Implementation**:
- **Theme Provider**: Complete theme management system with persistent storage
- **Light & Dark Themes**: Comprehensive color schemes for both light and dark modes
- **Dynamic Theme Switching**: Real-time theme switching across the entire application
- **Persistent Settings**: Theme preference saved and restored on app restart
- **Consistent UI**: All screens and components support both themes seamlessly

**Complete Stock Keeper Dashboard Implementation**:
- **Stock Management Screen**: Comprehensive inventory management with search, filtering, and status tracking
- **Stock Reports Screen**: Advanced analytics with key metrics, top items, and category breakdown
- **Settings Screen**: Complete app settings with account, preferences, security, notifications, and data management
- **Add Items Screen**: Detailed form for adding new inventory items with validation and auto-ID generation
- **Stock Transfer Screen**: Transfer inventory between locations with validation and tracking
- Enhanced navigation and integration with existing screens

**Fingerprint Authentication Fix**:
- Fixed credential synchronization between SharedPreferences and BiometricService
- Resolved issue where fingerprint login failed despite successful biometric testing
- Added debug logging for better troubleshooting
- Improved error handling and user feedback

**New Profile Management Features**:
- **Change Password Screen**: Complete password change functionality with validation
- **Update Profile Image Screen**: Profile image management with camera/gallery support
- **Face Detection**: AI-powered face detection to ensure profile images contain human faces
- Enhanced security with password requirements and validation
- Image optimization and preview functionality

**Technical Improvements**:
- Added proper route management for new screens
- Improved error handling and user feedback
- Enhanced UI/UX with consistent design patterns
- Added comprehensive validation and security measures
- Implemented demo data for testing and development

---

**Note**: This application is designed for internal use by Chev Energies staff. Please ensure proper training before using the application in production environments.
