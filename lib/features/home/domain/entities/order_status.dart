enum ActiveOrderPhase {
  /// Sipariş az önce kabul edildi, sürücü henüz yola çıkmadı.
  accepted,

  /// Sürücü müşteriye (A noktası) doğru yolda.
  headingToClient,

  /// Müşteri alındı, hedef noktaya (B noktası) doğru yolda.
  headingToDestination,
}

enum OrderStatus {
  offered,
  active,
}
