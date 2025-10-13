# Fix PDF Navigation with Auto-Preview (Option B)

## Problem
After downloading and previewing a PDF (which auto-opens), pressing back once shows the correct screen, but pressing back again skips intermediate screens and goes directly to the dashboard. This happens from any screen: Reports → Income Statement → Download PDF → Preview → Close → Back → Dashboard (skips Income Statement and Reports).

## Root Cause
The `OpenFile.open(file.path)` call in `_savePdf` opens the PDF in an external viewer, which is treated as a separate activity/screen in the navigation stack. When the PDF viewer closes, it returns to the app, but the navigation state is affected. Combined with the `PopScope` having `canPop: false`, the back button doesn't work properly from detail screens.

## Solution Strategy
Keep the automatic PDF opening for better UX, but fix the `PopScope` logic to properly handle back navigation from detail screens while still preventing app closure from main tabs.

The key insight is:
1. External PDF viewer (OpenFile) adds to the system navigation stack
2. Our `PopScope` with `canPop: false` prevents ALL back navigation
3. We need to allow back navigation when there are pushed routes (detail screens)
4. We need to prevent back navigation only when on main tabs (to avoid app closure)

## Implementation Plan

### 1. Fix WidgetTree PopScope Logic
**File:** `lib/features/presentation/widgets/widget_tree.dart`

Update the `PopScope` to:
- Keep `canPop: false` to intercept all back button presses
- In `onPopInvoked`, check if there are routes to pop
- If yes, manually pop to allow navigation from detail screens
- If no, do nothing to prevent app closure from main tabs

```dart
return PopScope(
  canPop: false, // Intercept all back button presses
  onPopInvoked: (didPop) {
    if (!didPop) {
      // Check if we're on a detail screen (pushed route)
      final navigator = Navigator.of(context);
      if (navigator.canPop()) {
        // We're on a detail screen, allow back navigation
        navigator.pop();
      } else {
        // We're on main tab, prevent app closure
        print('Back button pressed on main screen - preventing app closure');
      }
    }
  },
  child: Scaffold(...),
);
```

### 2. Fix EmployeeWidgetTree PopScope Logic
**File:** `lib/features/presentation/widgets/employee_widget_tree.dart`

Apply the same logic to the employee widget tree.

### 3. Ensure Dialogs Use Root Navigator
**Already Done** - All PDF/Excel download dialogs now use `Navigator.of(context, rootNavigator: true).pop()` to close, which prevents interference with the navigation stack.

## Why This Works

1. **PDF Preview Opens:** `OpenFile.open()` opens external viewer
2. **User Closes PDF:** Returns to app, navigation stack intact
3. **User Presses Back:** `PopScope` intercepts with `canPop: false`
4. **Check Routes:** `Navigator.canPop()` returns `true` (we're on Income Statement, not main tab)
5. **Manual Pop:** `navigator.pop()` navigates back to Reports screen
6. **User Presses Back Again:** `PopScope` intercepts again
7. **Check Routes:** `Navigator.canPop()` returns `false` (we're on Reports main tab)
8. **Prevent Closure:** Do nothing, stay on Reports screen

## Expected Behavior After Fix

### Scenario 1: Reports → Income Statement → Download PDF
1. User navigates: Dashboard → Reports Tab → Income Statement
2. User downloads PDF → PDF opens in external viewer
3. User closes PDF → Returns to Income Statement screen ✓
4. User presses back → Goes to Reports screen ✓
5. User presses back → Stays on Reports (main tab, prevents app closure) ✓

### Scenario 2: Employee Management → Employee Details → Payslip → Download PDF
1. User navigates: Dashboard → Employee Management → Employee Details → Payslip Details
2. User downloads PDF → PDF opens in external viewer
3. User closes PDF → Returns to Payslip Details ✓
4. User presses back → Goes to Employee Details ✓
5. User presses back → Goes to Employee Management ✓
6. User presses back → Stays on Employee Management (main tab) ✓

### Scenario 3: Invoice → Invoice Details → Download PDF
1. User navigates: Dashboard → Invoice Tab → Invoice Details
2. User downloads PDF → PDF opens in external viewer
3. User closes PDF → Returns to Invoice Details ✓
4. User presses back → Goes to Invoice screen ✓
5. User presses back → Stays on Invoice (main tab) ✓

## Key Benefits
- ✅ PDF auto-opens for better UX
- ✅ Back navigation works correctly through all screens
- ✅ Main tabs prevent accidental app closure
- ✅ Works with external PDF viewer
- ✅ Dialogs don't interfere (using rootNavigator)

## Files to Modify
1. `lib/features/presentation/widgets/widget_tree.dart` - Update PopScope logic
2. `lib/features/presentation/widgets/employee_widget_tree.dart` - Update PopScope logic

## Implementation Steps
1. Update WidgetTree PopScope to manually pop when routes are available
2. Update EmployeeWidgetTree PopScope with same logic
3. Test navigation flow with PDF downloads from various screens
4. Verify main tabs still prevent app closure

