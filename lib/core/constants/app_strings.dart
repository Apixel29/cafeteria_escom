/// Todas las cadenas de texto de la aplicación centralizadas.
///
/// Facilita la futura internacionalización (i18n) y evita
/// strings duplicados o "magic strings" en el código.
class AppStrings {
  AppStrings._();

  // ── App general ───────────────────────────────────────────
  static const String appName = 'CafeterIA ESCOM';
  static const String appTagline = 'Tu cafetería en la palma de tu mano';

  // ── Auth ──────────────────────────────────────────────────
  static const String login = 'Iniciar Sesión';
  static const String register = 'Crear Cuenta';
  static const String logout = 'Cerrar Sesión';
  static const String email = 'Correo electrónico';
  static const String password = 'Contraseña';
  static const String confirmPassword = 'Confirmar contraseña';
  static const String fullName = 'Nombre completo';
  static const String forgotPassword = '¿Olvidaste tu contraseña?';
  static const String recoverPassword = 'Recuperar contraseña';
  static const String loginWithGoogle = 'Continuar con Google';
  static const String noAccount = '¿No tienes cuenta? ';
  static const String hasAccount = '¿Ya tienes cuenta? ';
  static const String signIn = 'Inicia sesión';
  static const String signUp = 'Regístrate';

  // ── Validaciones ──────────────────────────────────────────
  static const String requiredField = 'Este campo es obligatorio';
  static const String invalidEmail = 'Ingresa un correo válido';
  static const String passwordTooShort = 'Mínimo 8 caracteres';
  static const String passwordsDoNotMatch = 'Las contraseñas no coinciden';
  static const String nameTooShort = 'El nombre debe tener al menos 3 caracteres';

  // ── Menú ──────────────────────────────────────────────────
  static const String menu = 'Menú';
  static const String searchProducts = 'Buscar productos...';
  static const String noProductsFound = 'No se encontraron productos';
  static const String addToCart = 'Agregar al carrito';
  static const String outOfStock = 'Agotado';
  static const String categories = 'Categorías';
  static const String allCategories = 'Todos';
  static const String offlineMode = 'Estás en modo sin conexión · Mostrando menú guardado';

  // ── Categorías ────────────────────────────────────────────
  static const String menuDelDia = 'Menú del Día';
  static const String botanas = 'Botanas';
  static const String galletas = 'Galletas';
  static const String bebidasEnergeticas = 'Bebidas Energéticas';
  static const String dulces = 'Dulces';
  static const String bebidasFrias = 'Bebidas Frías';
  static const String bebidasCalientes = 'Bebidas Calientes';
  static const String snacksSaludables = 'Snacks Saludables';

  // ── Carrito ───────────────────────────────────────────────
  static const String cart = 'Carrito';
  static const String emptyCart = 'Tu carrito está vacío';
  static const String emptyCartSubtitle = 'Agrega productos del menú para comenzar tu pedido';
  static const String removeItem = 'Eliminar';
  static const String specialNote = 'Nota especial (opcional)';
  static const String subtotal = 'Subtotal';
  static const String tax = 'IVA (16%)';
  static const String total = 'Total';
  static const String proceedToCheckout = 'Ir a pagar';

  // ── Checkout / Pago ───────────────────────────────────────
  static const String checkout = 'Resumen del pedido';
  static const String selectPaymentMethod = 'Método de pago';
  static const String creditCard = 'Tarjeta de crédito';
  static const String debitCard = 'Tarjeta de débito';
  static const String cash = 'Efectivo';
  static const String oxxoPay = 'OXXO Pay';
  static const String cardNumber = 'Número de tarjeta';
  static const String cardHolder = 'Titular de la tarjeta';
  static const String expiryDate = 'Fecha de vencimiento';
  static const String cvv = 'CVV';
  static const String confirmOrder = 'Confirmar pedido';
  static const String processingPayment = 'Procesando pago...';
  static const String paymentSuccess = '¡Pago exitoso!';
  static const String paymentFailed = 'Pago rechazado. Intenta de nuevo.';

  // ── Pedidos ───────────────────────────────────────────────
  static const String orders = 'Mis Pedidos';
  static const String orderDetail = 'Detalle del pedido';
  static const String orderNumber = 'Pedido #';
  static const String cancelOrder = 'Cancelar pedido';
  static const String cancelOrderConfirm = '¿Estás seguro de que deseas cancelar este pedido?';
  static const String orderPlaced = '¡Pedido realizado!';
  static const String orderConfirmed = '¡Pedido confirmado!';
  static const String orderReady = '¡Tu pedido está listo para recoger! 🎉';
  static const String noOrders = 'Aún no tienes pedidos';

  // ── Estados de pedido ─────────────────────────────────────
  static const String pending = 'Pendiente';
  static const String confirmed = 'Confirmado';
  static const String preparing = 'Preparando';
  static const String ready = 'Listo';
  static const String delivered = 'Entregado';
  static const String cancelled = 'Cancelado';

  // ── Perfil ────────────────────────────────────────────────
  static const String profile = 'Mi Perfil';
  static const String editProfile = 'Editar perfil';
  static const String changePhoto = 'Cambiar foto';
  static const String takePhoto = 'Tomar foto';
  static const String chooseFromGallery = 'Elegir de la galería';
  static const String phone = 'Teléfono';
  static const String saveChanges = 'Guardar cambios';

  // ── Admin ─────────────────────────────────────────────────
  static const String adminPanel = 'Panel Admin';
  static const String manageMenu = 'Gestionar Menú';
  static const String manageOrders = 'Gestionar Pedidos';
  static const String addProduct = 'Agregar producto';
  static const String editProduct = 'Editar producto';
  static const String deleteProduct = 'Eliminar producto';
  static const String deleteConfirm = '¿Eliminar este producto? Esta acción no se puede deshacer.';
  static const String productName = 'Nombre del producto';
  static const String productDescription = 'Descripción';
  static const String productPrice = 'Precio (MXN)';
  static const String productStock = 'Stock disponible';
  static const String productAvailable = 'Disponible para venta';

  // ── Acciones generales ────────────────────────────────────
  static const String save = 'Guardar';
  static const String cancel = 'Cancelar';
  static const String confirm = 'Confirmar';
  static const String delete = 'Eliminar';
  static const String edit = 'Editar';
  static const String retry = 'Reintentar';
  static const String goHome = 'Ir al inicio';
  static const String seeAll = 'Ver todo';
  static const String loading = 'Cargando...';
  static const String error = 'Ocurrió un error';
  static const String networkError = 'Sin conexión a internet';
  static const String unknownError = 'Error desconocido. Intenta de nuevo.';
}
