# HomeDriverSheet — Senior-Level Rewrite Prompt

## Context

Flutter driver app. The `HomeDriverSheet` is a bottom sheet sitting on top of a Google Maps view. The driver needs to see the map clearly, so the sheet must be freely resizable. There is an existing `DraggableScrollableSheet`-based implementation that is broken in a critical way: when inner content is scrollable (e.g., order detail), dragging down does not collapse the sheet because the inner `ScrollController` consumes the gesture first.

The sheet must support **5 distinct UI phases** and have **smart content-fit sizing**.

---

## Existing Code Structure (do not break these interfaces)

```
lib/features/home/
  domain/entities/
    home_sheet_phase.dart      — enum HomeSheetPhase { driverSummary, orderOffer, activeOrder }
    order.dart                 — Order, ActiveOrderPhase { toClient, toDestination }
    driver_session.dart        — DriverSession (isOnline, sheetPhase, offeredOrder, activeOrder)
  presentation/
    bloc/
      home_bloc.dart           — HomeBloc, HomeAction, HomeStatus
      home_event.dart          — HomeStartWorkRequested, HomeFinishWorkRequested,
                                  HomeAcceptOrderRequested, HomeDeclineOrderRequested,
                                  HomeAdvanceOrderRequested, HomeCompleteOrderRequested
      home_state.dart          — HomeState
    pages/
      home_page.dart           — _HomeViewState owns DraggableScrollableController
    widgets/
      home_driver_sheet.dart   — THE FILE TO REWRITE (core sheet infrastructure)
      home_sheet_content.dart  — routes to correct panel per phase
      home_driver_panel.dart   — offline / online driver summary panel
      home_order_offer_panel.dart   — incoming order panel (to redesign)
      home_active_order_panel.dart  — active order panel (to redesign)
      home_order_collapsed_panel.dart
      order_detail_body.dart
      home_primary_action_button.dart
  core/theme/color_const.dart  — ColorConst.primary, .black, .white, .grey, .lightGrey, .error
```

**BLoC events to fire (unchanged):**
- `HomeStartWorkRequested` / `HomeFinishWorkRequested`
- `HomeAcceptOrderRequested` / `HomeDeclineOrderRequested`
- `HomeAdvanceOrderRequested` (arrived at pickup → start trip)
- `HomeCompleteOrderRequested` (arrive at destination → complete)

---

## Core Problem to Fix: Gesture Conflict

`DraggableScrollableSheet` uses its child `ScrollController` to drive sheet expansion. When content is scrolled to the top and the user drags **down**, the sheet should collapse — but Flutter's gesture arena gives priority to the inner scroll, so the sheet never receives the drag.

**The correct fix** is a custom `ScrollPhysics` subclass that clamps the scroll to `0.0` when at the top edge and the user is pulling further down, effectively returning `overscroll` to the parent sheet. This is the pattern used by production apps (e.g., Yandex Go, Uber):

```dart
class _SheetScrollPhysics extends ClampingScrollPhysics {
  const _SheetScrollPhysics({super.parent});

  @override
  _SheetScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      _SheetScrollPhysics(parent: buildParent(ancestor));

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // When at the top and pulling down, let the sheet handle it
    if (value < position.pixels && position.pixels <= position.minScrollExtent) {
      return value - position.pixels;
    }
    return super.applyBoundaryConditions(position, value);
  }
}
```

Pass this physics to the `CustomScrollView` inside the sheet builder. This resolves the conflict without any `NotificationListener` hacks.

---

## Smart Sizing Requirements

### Rules
1. **`maxSheetFraction`** = `0.88` (88% of screen height). Sheet can never exceed this.
2. **`contentFitFraction`** = content intrinsic height / screen height. Computed after layout via `LayoutBuilder` + `GlobalKey` measuring the child.
3. **`effectiveMaxFraction`** = `min(contentFitFraction + headerFraction, maxSheetFraction)`
4. If `effectiveMaxFraction ≤ initialFraction`, the sheet does not snap upward (no scrolling needed, content fits).
5. If `effectiveMaxFraction > initialFraction`, snap positions include intermediate stops and the sheet becomes scrollable at the top.
6. `minFraction` = `0.13` — collapsed peek showing only the drag handle + one line of info.

### Snap stops per phase
| Phase              | Snaps                                              |
|--------------------|----------------------------------------------------|
| `driverSummary`    | `[min, contentFit]`                                |
| `orderOffer`       | `[min, 0.50, effectiveMax]`                        |
| `activeOrder`      | `[min, 0.42, effectiveMax]`                        |

### Content size measurement
Use a `_ContentSizeNotifier` — a `ChangeNotifier` that holds the measured child height. Wrap the sheet child in a `_MeasureSize` widget that uses a `LayoutBuilder` + `addPostFrameCallback` to report its `RenderBox.size.height` up to the notifier. The sheet listens and rebuilds `DraggableScrollableSheet` with the new `maxChildSize` and `snapSizes`.

---

## UI State Specifications

### State 1 — `driverSummary` + `isOnline: false` — "İşe Başlama"
```
┌─────────────────────────────────────────┐
│              ── (drag handle) ──        │
│  [Avatar]  Maksatbek          150 с  › │
│            Pazartesi, 30 haz.  3 sipariş│
│  ┌─────────────────────────────────────┐│
│  │  ▶▶  İşe Başla                      ││  ← FilledButton, primary color
│  └─────────────────────────────────────┘│
└─────────────────────────────────────────┘
```
Height: ~180 dp. Sheet snaps to `contentFit` only. No upward snap.

### State 2 — `driverSummary` + `isOnline: true` — "İşteyken"
```
┌─────────────────────────────────────────┐
│              ── (drag handle) ──        │
│  [Avatar]  Maksatbek          150 с  › │
│            Pazartesi, 30 haz.  3 sipariş│
│  ● Çevrimiçi   ──────────────────────  │  ← green dot + "online" badge
│  ┌─────────────────────────────────────┐│
│  │  ✕  İşi Bitir                       ││  ← FilledButton, grey/neutral
│  └─────────────────────────────────────┘│
└─────────────────────────────────────────┘
```
Height: ~190 dp. Waiting for orders. Stat cards optionally shown below button.

### State 3 — `orderOffer` — "Sipariş Geldi"
**Replace the current `HomePrimaryActionButton` accept button with a horizontal swipe-to-confirm widget.**

```
┌─────────────────────────────────────────┐
│              ── (drag handle) ──        │
│  🚨  Yeni Sipariş!          [timer: 12s]│  ← countdown ring, auto-decline at 0
│  ──────────────────────────────────────│
│  [order detail rows — see below]        │
│  ──────────────────────────────────────│
│  ┌──────────────────────────────────┐  │
│  │ ──────►  Siparişi Al  ──────►    │  ← SwipeActionButton
│  └──────────────────────────────────┘  │
│         [ Reddet ]                      │  ← TextButton, error color
└─────────────────────────────────────────┘
```

**`SwipeActionButton` spec:**
- Container: rounded rect, `primary.withOpacity(0.12)` background, `primary` border.
- Thumb: circular, `primary` fill, right-arrow icon, starts at left edge.
- User drags thumb right; at ≥ 80% width → haptic feedback (`HapticFeedback.mediumImpact`) → fire `onConfirmed`.
- If released before 80%, animate back to start with spring curve.
- Show "Siparişi Al" label centered, fades out as thumb covers it.
- Loading state: thumb replaced by `CircularProgressIndicator`.

**Countdown ring:**
- `AnimationController` counts down from `offerTimeoutSeconds` (default 20).
- `CustomPainter` draws an arc that shrinks.
- At 0, fire `HomeDeclineOrderRequested`.
- Must be cancellable when order is accepted.

### State 4 — `activeOrder` + `toClient` — "Müşteriye Git"
```
┌─────────────────────────────────────────┐
│              ── (drag handle) ──        │
│  🔵 Müşteriye gidiliyor                 │  ← status chip, blue
│  [order detail rows]                    │
│  ──────────────────────────────────────│
│  ┌──────────────────────────────────┐  │
│  │ ──────►  Geldim  ──────►         │  ← SwipeActionButton (green)
│  └──────────────────────────────────┘  │
└─────────────────────────────────────────┘
```
"Geldim" swipe → fires `HomeAdvanceOrderRequested`.

### State 5 — `activeOrder` + `toDestination` — "Hedefe Git / Siparişi Bitir"
```
┌─────────────────────────────────────────┐
│              ── (drag handle) ──        │
│  🟢 Hedefe gidiliyor                    │  ← status chip, green
│  [order detail rows]                    │
│  ──────────────────────────────────────│
│  ┌─────────────────────────────────────┐│
│  │  Siparişi Tamamla                   ││  ← regular FilledButton (no swipe needed)
│  └─────────────────────────────────────┘│
└─────────────────────────────────────────┘
```
Fires `HomeCompleteOrderRequested`.

---

## Order Detail Rows (`OrderDetailBody`)

Keep existing layout but polish:
```
  A  ●──── Gorky 1/2            0.7 km
           (pickup address)
  │
  B  ●──── Loginenko 10         4.0 km
           (destination address)

  [★ 4.7]  Müşteri Adı     [tag chip] [tag chip]
```
- Use `ColorConst.primary` for route line dots.
- Distance badges: small grey pill `Container`.
- Tag chips: `Chip` with `labelStyle fontSize: 11`, `visualDensity: compact`.

---

## Collapsed Peek State (all order phases)

When `sheetExtent ≤ minFraction + 0.04`:
```
┌─────────────────────────────────────────┐
│              ── (drag handle) ──        │
│  🔵 Müşteriye gidiliyor  ·  250 с   ↑ │
└─────────────────────────────────────────┘
```
Single-row summary. Tapping anywhere expands to default snap.

---

## `HomeDriverSheet` Widget API (revised)

```dart
class HomeDriverSheet extends StatefulWidget {
  const HomeDriverSheet({
    super.key,
    required this.controller,
    required this.phase,
    required this.initialChildSize,
    required this.child,
    this.onSizeChanged,       // (double extent) → void, for map padding
  });

  final DraggableScrollableController controller;
  final HomeSheetPhase phase;
  final double initialChildSize;
  final Widget child;
  final ValueChanged<double>? onSizeChanged;
```

- Remove `isCollapsed` and `onCollapse/onExpand` from the public API. The sheet manages its own collapsed state internally by listening to `controller`.
- Expose `static const minSize`, `maxSize`, `targetSizeFor()`, `snapSizesFor()` as before for `_HomeViewState` to read.
- Internally use a `ValueNotifier<double>` for child content height so `DraggableScrollableSheet` can be rebuilt with the correct `maxChildSize` via `StatefulBuilder` or `AnimatedBuilder`.

---

## `home_page.dart` changes

- Remove `isCollapsed` and `onCollapse/onExpand` props from `HomeDriverSheet` usage.
- `HomeSheetContent` still receives `isCollapsed` (computed from `_sheetExtent`), `onExpandSheet`.
- Map bottom padding: `mapBottomPadding = _sheetExtent * constraints.maxHeight`. Unchanged.

---

## Swipe Button Widget — Full Spec

Create `lib/shared/widgets/buttons/swipe_action_button.dart`:

```dart
class SwipeActionButton extends StatefulWidget {
  const SwipeActionButton({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.isLoading = false,
    this.color,              // defaults to ColorConst.primary
    this.height = 60.0,
  });
```

**Internal implementation:**
- Use a `GestureDetector` with `onHorizontalDragUpdate` + `onHorizontalDragEnd`.
- Track `_dragOffset` in `[0, maxDragWidth]`. `maxDragWidth = totalWidth - thumbDiameter - 8`.
- `_progress = _dragOffset / maxDragWidth`.
- Background fill: `color.withOpacity(0.08 + 0.12 * _progress)` — subtly brightens as you drag.
- Label opacity: `(1 - _progress * 1.5).clamp(0, 1)`.
- On release: if `_progress >= 0.80` → confirm. Else spring back.
  ```dart
  AnimationController(vsync: this, duration: const Duration(milliseconds: 380))
    ..addListener(() => setState(() => _dragOffset = _returnAnim.value))
  ```
- Spring back uses `CurvedAnimation(curve: Curves.elasticOut)`.

---

## File Change Checklist

| File | Action |
|------|--------|
| `home_driver_sheet.dart` | **Rewrite** — smart sizing, gesture fix, remove isCollapsed API |
| `home_sheet_content.dart` | Update to remove `isCollapsed` propagation to sheet; still passes to panels |
| `home_driver_panel.dart` | Add online status badge; no other structural change |
| `home_order_offer_panel.dart` | Replace `HomePrimaryActionButton` with `SwipeActionButton` + countdown ring |
| `home_active_order_panel.dart` | Replace arrived button with `SwipeActionButton`; complete = regular button |
| `home_order_collapsed_panel.dart` | Polish single-row layout |
| `order_detail_body.dart` | Polish route line + tag chips |
| `home_page.dart` | Remove isCollapsed/onCollapse/onExpand from sheet instantiation |
| `home_primary_action_button.dart` | Keep for `toDestination` complete button; remove from offer/toClient |
| `shared/widgets/buttons/swipe_action_button.dart` | **Create new** |

---

## API-Ready Architecture Notes

These hooks must exist so real API integration is drop-in:

1. **`DriverRepository`** already has the right abstraction layer. No changes needed.
2. **`HomeBloc`** events are already named for real API actions — do not rename.
3. **Countdown timer** in `orderOffer` panel: use `offerTimeoutSeconds` field. Add it to `Order` entity as `final int offerTimeoutSeconds` with a default of `20`. The mock datasource sets it to `20`. When the real API sends a timeout, the field is populated. The countdown `AnimationController` reads from this field.
4. **Driver location streaming**: `home_page.dart` already calls `Geolocator.getCurrentPosition()`. For real-time tracking, replace with `Geolocator.getPositionStream()` and dispatch a `HomeLocationUpdated(LatLng)` event. Add the event to `home_event.dart` now but leave the bloc handler as a no-op stub.
5. **Order ETA / distance badges**: `Order` already has `distanceToClientKm` and `distanceToPointKm`. The active order panels should display these. When the real API provides live ETA, add `etaMinutes` to `Order` and display it in the status chip.

---

## Quality Bar

- Zero `setState` in `HomeDriverSheet` except for the content-size notifier rebuild.
- All animations use `AnimationController` — no `Future.delayed` hacks.
- `SwipeActionButton` is fully accessible: `Semantics(label: label, button: true)` wrapper.
- No hardcoded strings — use `LocaleKeys` (easy_localization).
- Colors only from `ColorConst` — no inline `Color(0xFF...)`.
- Every widget `const`-constructible where possible.
- `DraggableScrollableSheet.snap: true` with explicit `snapSizes` — no free-floating stops.
