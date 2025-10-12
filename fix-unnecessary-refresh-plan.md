# Fix Unnecessary Screen Refresh on Navigation

## Problem

When navigating between screens, the app constantly refreshes and reloads data even though Riverpod is being used for state management. This causes:
- Poor user experience (loading spinners on every navigation)
- Unnecessary API calls
- Wasted bandwidth and resources
- Slower app performance

## Root Cause

The issue is caused by using `FutureProvider.family` without caching. These providers automatically refetch data every time:
1. The screen is rebuilt
2. Navigation occurs
3. The provider is watched again

**Current problematic providers:**
- `invoicesByUserProvider` - Refetches all invoices on every navigation
- `invoiceByIdProvider` - Refetches invoice details on every navigation
- Any other `FutureProvider.family` without `autoDispose` modifier

## Solution Options

### Option A: Use `keepAlive` with FutureProvider (Recommended)
Keep the data cached and only refetch when explicitly needed.

```dart
// Before:
final invoicesByUserProvider = FutureProvider.family<List<Invoice>, String>((ref, userId) async {
  final getInvoices = ref.read(getInvoicesByUserUseCaseProvider);
  return await getInvoices(userId);
});

// After:
final invoicesByUserProvider = FutureProvider.family<List<Invoice>, String>((ref, userId) async {
  // Keep the data alive (cached) even when no longer watched
  ref.keepAlive();
  
  final getInvoices = ref.read(getInvoicesByUserUseCaseProvider);
  return await getInvoices(userId);
});
```

### Option B: Convert to StateNotifierProvider with Manual Refresh
Use StateNotifier for better control over when data is fetched.

```dart
// Create a state class
class InvoicesState {
  final List<Invoice> invoices;
  final bool isLoading;
  final String? error;
  
  InvoicesState({
    required this.invoices,
    required this.isLoading,
    this.error,
  });
}

// Create a notifier
class InvoicesNotifier extends StateNotifier<InvoicesState> {
  final GetInvoicesByUser _getInvoicesUseCase;
  
  InvoicesNotifier(this._getInvoicesUseCase) 
    : super(InvoicesState(invoices: [], isLoading: false));
  
  Future<void> loadInvoices(String userId) async {
    if (state.isLoading) return; // Prevent duplicate calls
    
    state = InvoicesState(invoices: state.invoices, isLoading: true);
    
    try {
      final invoices = await _getInvoicesUseCase(userId);
      state = InvoicesState(invoices: invoices, isLoading: false);
    } catch (e) {
      state = InvoicesState(
        invoices: state.invoices,
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  void refresh(String userId) {
    loadInvoices(userId);
  }
}
```

### Option C: Use AsyncNotifier (Riverpod 2.0+)
Modern approach with better async handling.

## Recommended Implementation

**Use Option A (keepAlive)** for quick fix with minimal code changes:

### Files to Modify

1. **`lib/dependency_injection/riverpod_providers.dart`**
   - Add `ref.keepAlive()` to `invoicesByUserProvider`
   - Add `ref.keepAlive()` to `invoiceByIdProvider`
   - Review and add to any other `FutureProvider.family` that shouldn't auto-refresh

### Implementation Steps

#### Step 1: Fix Invoice Providers

```dart
// Line 626-629
final invoicesByUserProvider = FutureProvider.family<List<Invoice>, String>((ref, userId) async {
  ref.keepAlive(); // ← Add this line
  final getInvoices = ref.read(getInvoicesByUserUseCaseProvider);
  return await getInvoices(userId);
});

// Line 632-635
final invoiceByIdProvider = FutureProvider.family<Invoice, String>((ref, invoiceId) async {
  ref.keepAlive(); // ← Add this line
  final getInvoice = ref.read(getInvoiceByIdUseCaseProvider);
  return await getInvoice(invoiceId);
});
```

#### Step 2: Add Manual Refresh Methods (Optional)

For screens that need to manually refresh data, add refresh methods:

```dart
// In the screen widget
final refreshInvoices = useCallback(() {
  ref.invalidate(invoicesByUserProvider(userId));
}, [userId]);

// Then use it:
ElevatedButton(
  onPressed: refreshInvoices,
  child: Text('Refresh'),
)
```

#### Step 3: Review Other FutureProviders

Check for other `FutureProvider.family` instances that might have the same issue:
- Search for `FutureProvider.family` in the codebase
- Add `ref.keepAlive()` to providers that should cache data
- Use `autoDispose` modifier for providers that should refresh (like real-time data)

## Benefits

✅ **No unnecessary API calls** - Data is cached and reused
✅ **Better performance** - Screens load instantly with cached data
✅ **Better UX** - No loading spinners on navigation
✅ **Reduced bandwidth** - Fewer network requests
✅ **Proper state management** - Leverages Riverpod's caching capabilities
✅ **Manual refresh available** - Can still refresh when needed with `ref.invalidate()`

## Testing

After implementation, test:
1. Navigate to invoice screen → should load data
2. Navigate away and back → should show cached data instantly
3. Pull to refresh (if implemented) → should refetch data
4. App restart → should refetch data (cache is cleared)

## Notes

- `keepAlive()` keeps the provider's state in memory even when no widgets are watching it
- The cache persists until the app is closed or `ref.invalidate()` is called
- For data that changes frequently, consider using `autoDispose` instead
- For real-time data, use WebSocket or polling with StateNotifier

