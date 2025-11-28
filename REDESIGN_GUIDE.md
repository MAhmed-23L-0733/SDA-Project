# BookFlee Redesign Guide - Light Theme with Purple Accents

## Design System

### Colors

**Light Mode:**

- Background: `Color(0xFFF5F5F5)` (light gray)
- Card/Surface: `Colors.white`
- Primary (Purple): `Color(0xFF7C4DFF)`
- Secondary: `Color(0xFF9575CD)`
- Text: `Colors.black87` / `Colors.black54`
- Borders: `primary.withOpacity(0.3)`

**Dark Mode:**

- Background: `Color(0xFF121212)`
- Card/Surface: `Color(0xFF1E1E1E)`
- Primary: `Color(0xFF9575CD)`
- Secondary: `Color(0xFFB39DDB)`
- Text: `Colors.white` / `Colors.white70`
- Borders: `primary.withOpacity(0.3)`

### Components

#### Cards

Replace glassmorphism with clean white/dark cards:

```dart
Card(
  elevation: isDark ? 4 : 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: BorderSide(
      color: theme.colorScheme.primary.withOpacity(0.3),
      width: 1,
    ),
  ),
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: // content
  ),
)
```

#### Text Fields

```dart
TextField(
  decoration: InputDecoration(
    filled: true,
    fillColor: theme.colorScheme.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: theme.colorScheme.primary.withOpacity(0.3),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: theme.colorScheme.primary,
        width: 2,
      ),
    ),
  ),
)
```

#### Buttons (Purple Gradient)

```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        theme.colorScheme.primary,
        theme.colorScheme.secondary,
      ],
    ),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: theme.colorScheme.primary.withOpacity(0.3),
        blurRadius: 12,
        offset: Offset(0, 6),
      ),
    ],
  ),
  child: ElevatedButton(
    onPressed: () {},
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      shadowColor: Colors.transparent,
      elevation: 0,
    ),
    child: Text('Button'),
  ),
)
```

## Files to Update

### 1. Main App Theme (✅ DONE)

- `lib/main.dart` - Updated with proper light/dark themes

### 2. Navigation (✅ DONE)

- `lib/views/widget_tree.dart` - AppBar updated
- `lib/widgets/navbar_widget.dart` - Bottom nav updated

### 3. Pages to Update

#### Home Page (`lib/views/pages/home_page.dart`)

- Remove background gradient/image
- Use `theme.scaffoldBackgroundColor`
- Replace glass search card with white Card widget
- Update text fields to use theme colors
- Keep purple gradient on search button

#### Route Detail Page (`lib/views/pages/route_detail_page.dart`)

- Remove background gradient/image
- Use white cards for route info, journey details, seats
- Keep purple accents on selected seats
- Red for sold seats (already done)
- Update pricing card

#### My Bookings Page (`lib/views/pages/my_bookings_page.dart`)

- Remove background gradient/image
- Use white cards for each booking
- Purple border/accent on cards
- Keep green for "Confirmed" badges

#### Hero/Landing Page (`lib/views/pages/hero_page.dart`)

- Keep some visual flair but lighter
- Use white cards for sign in/up buttons
- Purple gradient backgrounds

#### Sign In/Up Pages

- White cards for forms
- Purple gradient buttons
- Clean, minimal design

## Implementation Steps

1. ✅ Update main theme (DONE)
2. ✅ Update navigation components (DONE)
3. Update each page:
   a. Remove `BoxDecoration` with gradients from body Container
   b. Replace `BackdropFilter` with `Card` widgets
   c. Update all hardcoded colors to use `theme.colorScheme.primary/secondary`
   d. Test in both light and dark modes

## Quick Find & Replace Patterns

### Remove Background Gradients

Find:

```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(...)
  ),
```

Replace with:

```dart
Container(
  color: theme.scaffoldBackgroundColor,
```

### Replace Glass Cards

Find:

```dart
BackdropFilter(
  filter: ImageFilter.blur(sigmaX: X, sigmaY: Y),
  child: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.white.withOpacity(0.X), ...]
      ),
    ),
  ),
)
```

Replace with:

```dart
Card(
  elevation: isDark ? 4 : 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: BorderSide(
      color: theme.colorScheme.primary.withOpacity(0.3),
    ),
  ),
  child: Padding(padding: const EdgeInsets.all(20), child: ...)
)
```

### Update Text Colors

Find: `color: Colors.white` or `color: Colors.white70`
Replace with: `color: isDark ? Colors.white : Colors.black87`

Find: `color: Colors.black` or similar
Replace with: `color: isDark ? Colors.white87 : Colors.black`
