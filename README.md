# HW 3 - Dry

## Question 1 
The class that is used to implement the controller patern in the library attached in the quesiton is: SnappingSheetController.
As found in the class documentation there are several features that the controller allows the developer to control, such as:
	- snapToPosition - snaps to a given snapping position
	- setSnappingSheetFactor - sets the position of the snapping sheet directly without animation
	- stopCurrentSnapping - if exists, stops the current snapping

In conclution we can deduce that the controller provides the developer tools to easily make changes in the snapping sheet.

## Question 2
The parameter that allowes that bottom sheet to snap into position with differenct animations is *snappingPosition*
as shown in the documentation:

>class SnappingPosition {
>  final double? _positionPixel;
>  final double? _positionFactor;

>  /// The snapping position alignment regarding the grabbing content.

>  /// This is often used when you want a snapping position at the top or bottom
>  /// of the screen, but want the entire grabbing widget to be visible.

>  /// For example, if you have a snapping position at the top of the screen,
>  /// you usually use [GrabbingContentOffset.bottom]. See example:
>  /// ```dart
>  /// SnappingPosition.factor(
>  ///   positionFactor: 1.0,
>  ///   grabbingContentOffset: GrabbingContentOffset.bottom,
>  /// ),
>  /// ```

>  /// Or if you have a snapping position at the bottom of the screen, you
>  /// usually use [GrabbingContentOffset.bottom]. See example:
>  /// ```dart
>  /// SnappingPosition.factor(
>  ///   positionFactor: 0.0,
>  ///   grabbingContentOffset: GrabbingContentOffset.top,
>  /// ),
>  /// ```

As shown in the documentation above, one can control the snappingPosition with the instance, and changing its parameters.

## Question 3

*InkWell* and *GestureDetector* are mainly alike, both privde many common features like _onTap_ and _onLongPress_

### Advantages:

InkWell - GestureDetector doen't include ripple effect tap, which InkWell does, so if a developer requires thi effect, he should choose InkWell

GestureDetector - cater to much broader spectrum than InkWell, GestureDetector is better for detecting the user's gesture, and interact with the screen in many wais, furthermore GestureDetector doesn't have to have a Material Widget as an ancestor.



