/// Type of event sent to VK Ads Full Stream Attribution.
enum RuStoreFsaEventType {
  /// Application install. Does not require a product ID.
  install('install', false),

  /// User viewed an offer. Requires a product ID.
  viewOffer('viewOffer', true),

  /// User added a product to the cart. Requires a product ID.
  addToCart('addToCart', true),

  /// User made a purchase. Requires a product ID.
  purchase('purchase', true),

  /// User added a product to the wishlist. Requires a product ID.
  addToWishlist('addToWishlist', true);

  const RuStoreFsaEventType(this.value, this.requiresProductId);

  /// Name of the event type passed to the native SDK.
  final String value;

  /// Whether `productId` must be provided for this event type.
  final bool requiresProductId;
}
