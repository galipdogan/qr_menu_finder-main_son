/// Kullanıcı dostu hata mesajları
class ErrorMessages {
  // Network errors
  static const String noInternet =
      'İnternet bağlantınızı kontrol edin ve tekrar deneyin.';
  static const String serverError =
      'Sunucuya bağlanırken bir sorun oluştu. Lütfen daha sonra tekrar deneyin.';
  static const String timeout =
      'İstek zaman aşımına uğradı. Lütfen tekrar deneyin.';

  // Restaurant errors
  static const String restaurantNotFound =
      'Restoran bulunamadı. Restoran kaldırılmış olabilir.';
  static const String noRestaurantsNearby =
      'Yakınınızda restoran bulunamadı. Farklı bir konum deneyin.';
  static const String noRestaurantsFoundForSearch =
      'Aradığınız kritere uygun restoran bulunamadı.';
  static const String restaurantLoadFailed =
      'Restoranlar yüklenirken bir hata oluştu. Lütfen tekrar deneyin.';
  static const String restaurantAddFailed = 'Restoran eklenirken bir hata oluştu. Lütfen tekrar deneyin.';
  static const String restaurantUpdateFailed = 'Restoran bilgileri güncellenirken bir hata oluştu. Lütfen tekrar deneyin.';
  static const String restaurantDeleteFailed = 'Restoran silinirken bir hata oluştu. Lütfen tekrar deneyin.';

  // Location errors
  static const String locationPermissionDenied =
      'Konum izni gerekli. Ayarlardan konum iznini açabilirsiniz.';
  static const String locationServiceDisabled =
      'Konum servisi kapalı. Lütfen konum servisini açın.';
  static const String locationFetchFailed =
      'Konumunuz alınamadı. Lütfen tekrar deneyin.';
    static const String locationLoading = 'Konum alınıyor...';
    static const String selectLocation = 'Konum seçin';

  // Auth errors
  static const String notAuthenticated =
      'Bu işlem için giriş yapmalısınız.';
  static const String invalidCredentials =
      'E-posta veya şifre hatalı. Lütfen kontrol edin.';
  static const String userNotFound =
      'Kullanıcı bulunamadı. Kayıt olmayı deneyin.';
  static const String emailAlreadyInUse =
      'Bu e-posta adresi zaten kullanılıyor.';
  static const String weakPassword =
      'Şifre çok zayıf. En az 6 karakter kullanın.';
  static const String invalidEmail =
      'Geçersiz e-posta adresi. Lütfen kontrol edin.';
  static const String accountDeletionFailed = 'Hesap silinirken bir hata oluştu. Lütfen tekrar deneyin.';

  // Menu errors
  static const String menuNotFound =
      'Menü bulunamadı. Restorana henüz menü eklememiş olabilir.';
  static const String menuLoadFailed =
      'Menü yüklenirken bir hata oluştu. Lütfen tekrar deneyin.';
    static const String menuCategoryEmpty =
      'Bu kategoride menü öğesi bulunamadı.';
    static const String menuEmptyForRestaurant =
      'Bu restoran için henüz menü eklenmemiş.';
    static const String menuTitle = 'Menü';
    static const String menuEmptyPrompt =
      'Menü öğelerini görüntülemek için yenileyin.';
  static const String menuItemAddFailed = 'Menü öğesi eklenirken bir hata oluştu. Lütfen tekrar deneyin.';
  static const String menuItemUpdateFailed = 'Menü öğesi güncellenirken bir hata oluştu. Lütfen tekrar deneyin.';
  static const String menuItemDeleteFailed = 'Menü öğesi silinirken bir hata oluştu. Lütfen tekrar deneyin.';

      // Search
      static const String searchHint = 'Yemek veya restoran ara...';
      static const String searchStartTitle = 'Arama Yap';
      static const String searchStartSubtitle =
        'Yemek veya restoran aramak için yukarıdaki arama çubuğunu kullanın';
      static const String searching = 'Aranıyor...';
      static const String searchNoResultsTitle = 'Sonuç Bulunamadı';
      static const String searchNoResultsSubtitle =
        'Aramanızla eşleşen sonuç bulunamadı. Lütfen farklı bir arama yapın.';


      // Filter & Sort
      static const String filterSortTitle = 'Filtrele & Sırala';
      static const String reset = 'Sıfırla';
      static const String sortLabel = 'Sırala';
      static const String sortDistance = 'Mesafe';
      static const String sortRating = 'Puan';
      static const String sortReviewCount = 'Yorum Sayısı';
      static const String sortName = 'İsim';
      static const String minRatingLabel = 'Minimum Puan';
      static const String categoriesLabel = 'Kategoriler';
      static const String categoryNotFound = 'Kategori bulunamadı';
      static const String apply = 'Uygula';

      // Settings
      static const String settingsTitle = 'Ayarlar';
      static const String settingsLoadFailed = 'Ayarlar yüklenemedi.';
      static const String errorPrefix = 'Hata:';
      static const String generalSection = 'Genel';
      static const String notificationsTitle = 'Bildirimler';
      static const String notificationsSubtitle = 'Promosyon ve güncellemeler hakkında bildirim al';
      static const String languageTitle = 'Dil';
      static const String turkish = 'Türkçe';
      static const String english = 'English';
      static const String themeTitle = 'Tema';
      static const String system = 'Sistem';
      static const String light = 'Açık';
      static const String dark = 'Koyu';

      // Generic
      static const String somethingWentWrong = 'Bir şeyler yanlış gitti';
      static const String retryPrompt = 'Lütfen tekrar deneyin';

      // Restaurants / Listing
      static const String nearbyRestaurants = 'Yakındaki Restoranlar';
      static const String searchResults = 'Arama Sonuçları';
      static const String restaurantListEmptyTitle = 'Restoran Bulunamadı';
      static const String restaurantListEmptySearch =
        'Arama kriterlerinize uygun restoran bulunamadı.';
      static const String restaurantListEmptyNearby = 'Bu bölgede restoran bulunamadı.';
      static const String restaurantsTitle = 'Restoranlar';
      static const String restaurantsInstruction =
        'Restoranları görüntülemek için konum bilginizi paylaşın.';

      // History
      static const String historyTitle = 'Geçmiş';
      static const String confirmClearHistoryTitle = 'Geçmişi Temizle';
      static const String confirmClearHistoryContent =
        'Tüm geçmiş kayıtlarınız silinecek. Emin misiniz?';
      static const String cancel = 'İptal';
      static const String clear = 'Temizle';
      static const String mustLogin = 'Giriş Yapmalısınız';
      static const String mustLoginForHistory = 'Geçmişinizi görmek için lütfen giriş yapın.';
      static const String historyCleared = 'Geçmiş temizlendi';
      static const String historyClearing = 'Geçmiş temizleniyor...';
      static const String historyLoading = 'Geçmiş yükleniyor...';
      static const String historyEmptyTitle = 'Henüz Geçmiş Yok';
      static const String historyEmptySubtitle =
        'Ziyaret ettiğiniz restoranlar ve görüntülediğiniz menüler burada görünecek.';
      static const String goBack = 'Geri Dön';

      // Favorites
      static const String favoritesTitle = 'Favorilerim';
      static const String mustLoginForFavorites = 'Favorilerinizi görmek için lütfen giriş yapın.';
      static const String favoritesLoading = 'Favoriler yükleniyor...';
      static const String favoritesEmptyTitle = 'Henüz Favori Yok';
      static const String favoritesEmptySubtitle =
        'Beğendiğiniz restoranları favorilere ekleyerek buradan kolayca ulaşabilirsiniz';
      static const String exploreRestaurants = 'Restoranları Keşfet';
      static const String restaurantInfoLoading = 'Restoran bilgileri yükleniyor...';
      static const String tryAgain = 'Tekrar Dene';
      static const String favoriteAdded = 'Favorilere eklendi';
      static const String favoriteRemoved = 'Favorilerden çıkarıldı';

      // Reviews
      static const String reviewsTitle = 'Yorumlarım';
      static const String reviewsLoading = 'Yorumlar yükleniyor...';
      static const String reviewsEmptyTitle = 'Henüz Yorum Yok';
      static const String reviewsEmptySubtitle =
        'Restoranlar hakkında yaptığınız yorumlar ve değerlendirmeler burada görünecek.';
      // Review dialog / labels
      static const String editReviewTitle = 'Yorumu Düzenle';
      static const String ratingLabel = 'Puanlama';
      static const String reviewLabel = 'Yorumunuz';
      static const String save = 'Kaydet';
      // Review messages
      static const String reviewLoadFailedPrefix = 'Yorumlar yüklenirken hata oluştu:';
      static const String reviewDeleteSuccess = 'Yorum başarıyla silindi';
      static const String reviewDeleteFailedPrefix = 'Yorum silinirken hata oluştu:';
      static const String reviewUpdateFailedPrefix = 'Yorum güncellenirken hata oluştu:';
      static const String reviewUpdateSuccess = 'Yorum başarıyla güncellendi';
      static const String reviewUpdateUnexpectedFailedPrefix = 'Yorum güncellenirken beklenmedik bir hata oluştu:';

      // Router / pages
      static const String pageNotFoundPrefix = 'Sayfa bulunamadı:';
      static const String goHome = 'Ana Sayfaya Dön';
        // Search history widget
        static const String searchHistoryEmptyTitle = 'Henüz arama geçmişi yok';
        static const String searchHistoryEmptySubtitle =
          'Arama yaptığınızda geçmişiniz burada görünecek';
        static const String recentSearches = 'Son Aramalar';
        // Misc
        static const String pendingLabel = 'Beklemede';
        static const String outOfStock = 'Tükendi';
        static const String priceHistoryLabel = 'Geçmiş';
        // Profile / Owner panel
        static const String profileTitle = 'Profil';
        static const String ownerPanelTitle = 'İşletme Paneli';
        static const String ownerNoActivity = 'Henüz aktivite yok';
        static const String addRestaurantSuccess = 'Restoran başarıyla eklendi!';
        static const String addRestaurant = 'Restoran Ekle';
        static const String login = 'Giriş Yap';
        static const String loginRequired = 'Giriş Gerekli';
        static const String upgradeToOwner = 'İşletme Hesabına Yükselt';
        static const String accessOwnerPanel = 'İşletme Paneline Eriş';
        static const String manageRestaurants = 'Restoranları Yönet';
        static const String manageMenus = 'Menüleri Yönet';
        static const String manageReviews = 'Yorumları Yönet';
        static const String viewStatistics = 'İstatistikleri Görüntüle';
        static const String ownerPanelLoading = 'İşletme paneli yükleniyor...';
        static const String ownerPanelError = 'İşletme paneli yüklenemedi.';
        static const String noRecentActivities = 'Son aktiviteler bulunamadı.';
        static const String viewAllActivities = 'Tüm Aktiviteleri Görüntüle';
        static const String manageYourRestaurants = 'Restoranlarınızı buradan yönetin.';
        static const String manageYourMenus = 'Menülerinizi buradan yönetin.';
        static const String manageYourReviews = 'Müşteri yorumlarını buradan yönetin.';
        static const String viewYourStatistics = 'Restoran istatistiklerinizi buradan görüntüleyin.';
        static const String ownerPanelLoadFailedPrefix = 'İşletme paneli yüklenirken hata oluştu:';
        static const String statsLoadFailedPrefix = 'İstatistikler yüklenirken hata oluştu:';
        static const String emailLabel = 'E-posta';
        // Labels
        static const String restaurantLabel = 'Restoran';
        static const String menuLabel = 'Menü';
        // Owner panel specific
        static const String ownerPanelLoginPrompt = 'İşletme paneline erişmek için lütfen giriş yapın';
        static const String ownerUpgradeTitle = 'İşletme Hesabı';
        static const String ownerUpgradeSubtitle = 'Restoranınızı platforma ekleyin ve menülerinizi kolayca yönetin';
        static const String ownerFeatureMenuManagement = 'Menü Yönetimi';
        static const String ownerFeatureMenuManagementDesc = 'QR kod ile menülerinizi kolayca güncelleyin';
        static const String ownerFeatureStats = 'İstatistikler';
        static const String ownerFeatureStatsDesc = 'Restoranınızın performansını takip edin';
        static const String ownerFeatureReviews = 'Müşteri Yorumları';
        static const String ownerFeatureReviewsDesc = 'Müşteri geri bildirimlerini görün ve yanıtlayın';
        static const String ownerFeatureNotifications = 'Anlık Bildirimler';
        static const String ownerFeatureNotificationsDesc = 'Yeni yorumlar ve güncellemelerden haberdar olun';
        static const String ownerApplyButton = 'İşletme Hesabı Başvurusu Yap';
        static const String ownerMoreInfo = 'Daha fazla bilgi';
        static const String comingSoon = 'Yakında';
        static const String qrScanComingSoon = 'QR tarama yakında!';
        static const String reportsComingSoon = 'Raporlar yakında!';
        static const String quickActions = 'Hızlı İşlemler';
        static const String recentActivities = 'Son Aktiviteler';
        static const String welcomePrefix = 'Hoş geldiniz,';
        // Profile / Edit profile
        static const String profileUpdatedSuccess = 'Profil başarıyla güncellendi!';
        static const String editProfileTitle = 'Profili Düzenle';
        static const String emailCannotChange = 'E-posta adresi değiştirilemez';
        static const String accountTypeLabel = 'Hesap Türü';
        static const String saveChangesLabel = 'Değişiklikleri Kaydet';
        static const String nameLabel = 'Ad Soyad *';
        static const String nameRequired = 'Ad soyad gerekli';
        static const String ownerApplicationTitle = 'İşletme Hesabı Başvurusu';
        static const String ownerApplicationContent = 'İşletme hesabı başvurusu özelliği yakında aktif olacak.\n\nRestoran bilgilerinizi ve belgelerinizi yükleyerek işletme hesabına geçiş yapabileceksiniz.';
        static const String ownerPanelAboutTitle = 'İşletme Paneli Hakkında';
        static const String ownerPanelAboutContent = 'İşletme Paneli ile neler yapabilirsiniz?\n\n• Restoranlarınızı ekleyin ve yönetin\n• Menülerinizi QR kod ile güncelleyin\n• Müşteri yorumlarını görün\n• Fiyat geçmişini takip edin\n• İstatistikleri izleyin\n\nİşletme hesabı oluşturmak için:\n1. İşletme belgelerinizi hazırlayın\n2. Başvuru yapın\n3. Onay bekleyin (24-48 saat)\n4. Onaylandıktan sonra panel aktif olur';
        // Profile / account
        static const String accountSection = 'Hesabım';
        static const String myCommentsSubtitle = 'Yaptığım yorumlar';
        static const String visitedPlacesSubtitle = 'Ziyaret ettiğim yerler';
        static const String profileInfoTitle = 'Profil Bilgileri';
        static const String profileInfoSubtitle = 'Ad, e-posta';
        //static const String notificationsTitle = 'Bildirimler';
        // static const String notificationsSubtitle = 'Bildirim tercihleri';
        // static const String languageTitle = 'Dil';
        // static const String turkish = 'Türkçe';
        static const String businessAccountTitle = 'İşletme Hesabı';
        static const String businessAccountSubtitle = 'Restoranınızı ekleyin, menülerinizi yönetin';
        static const String businessAccountSoon = 'İşletme hesabı kaydı yakında aktif olacak!';
        static const String openBusinessAccount = 'İşletme Hesabı Aç';
        static const String logoutTitle = 'Çıkış Yap';
        static const String logoutConfirm = 'Çıkış yapmak istediğinize emin misiniz?';
        // Roles
        static const String roleUser = 'Kullanıcı';
        static const String roleOwner = 'İşletme Sahibi';
        static const String roleAdmin = 'Yönetici';
        static const String rolePendingOwner = 'İşletme Başvurusu Bekliyor';
        // QR Scanner / Add menu
        static const String qrAddMenuTitle = 'Menü Ekle';
        static const String qrAddMenuUrlPrompt = 'Bu URL\'den menü eklemek ister misiniz?';
        static const String qrAddMenuContentPrompt = 'Bu içerikten menü eklemek ister misiniz?';
        static const String rescan = 'Tekrar Tara';
        static const String close = 'Kapat';
        static const String qrCameraErrorPrefix = 'Kamera hatası:';
        static const String qrInstructionTitle = 'QR kodu kare içine alın';
        static const String qrInstructionSubtitle = 'Restoran menüsü veya QR menü kodunu tarayın';
        static const String scanQr = 'QR Kod Tara';
        static const String more = 'Daha Fazla';
        static const String mapView = 'Harita Görünümü';
        // Menu / Item messages
        static const String all = 'Tümü';
        static const String otherCategory = 'Diğer';
        static const String itemLoading = 'Ürün yükleniyor...';
        static const String itemDetailLoadFailed = 'Ürün detayları yüklenemedi.';
        static const String itemLoadFailedPrefix = 'Ürün yüklenirken hata oluştu:';
        static const String invalidMenuSelection = 'Lütfen geçerli bir menü seçin';
        static const String menuAddedSuccess = '✅ Menü başarıyla eklendi!';
        static const String photoSelectErrorPrefix = 'Fotoğraf seçilirken hata oluştu:';
        static const String photoCaptureErrorPrefix = 'Fotoğraf çekilirken hata oluştu:';
        static const String restaurantSelectionRequired = 'Restoran Seçimi Gerekli';
        static const String restaurantSelectionDesc = 'Menü eklemek için önce hangi restorana ait olduğunu belirtmeniz gerekiyor.';
        static const String restaurantSearchLabel = 'Restoran Ara ve Seç';
        static const String newRestaurantLabel = 'Yeni Restoran Oluştur';
        static const String restaurantSelectTitle = 'Restoran Seç';
        static const String menuAddTitle = 'Menü Ekle';
        static const String menuUploadTitle = 'Menü Yükleme';
        static const String uploadMethodLabel = 'Yükleme Yöntemi';
        static const String selectedPhotoLabel = 'Seçilen Fotoğraf';
        static const String menuPhotoUrlLabel = 'Menü Fotoğrafı URL\'si';
        static const String urlHint = 'https://example.com/menu.jpg';
        static const String urlRequired = 'Lütfen URL girin';
        static const String urlInvalid = 'Geçerli bir URL girin (http:// veya https://)';
        static const String qrContentLabel = 'QR Kod İçeriği';
        static const String uploadAndProcess = 'Menüyü Yükle ve İşle';
        static const String restaurantIdNotFound = 'Restaurant ID bulunamadı';
        static const String menuUploadInstructions = '1. Menü fotoğrafını galeriden seçin, kamera ile çekin veya URL girin\n2. Sistem otomatik olarak menü öğelerini tanıyacak\n3. Tanınan öğeleri kontrol edip düzenleyebilirsiniz';
        // Search / Filters
        static const String filtersTitle = 'Filtreler';
        //static const String clear = 'Temizle';
        static const String citySimple = 'Şehir';
        static const String categoryLabel = 'Kategori';
        static const String priceRangeLabel = 'Fiyat Aralığı';
        static const String minPriceLabel = 'Min (₺)';
        static const String maxPriceLabel = 'Max (₺)';
        //static const String all = 'Tümü';

        // Price comparison
        static const String priceComparisonTitle = 'Diğer Restoranlardaki Fiyatlar';
        static const String priceSearching = 'Fiyatlar aranıyor...';
        static const String priceLoadFailedPrefix = 'Fiyatlar yüklenemedi:';
        static const String priceNotFound = 'Bu ürün için başka restoranda fiyat bulunamadı.';
        static const String bestLabel = 'EN UYGUN';
        static const String bestSubtitle = 'En uygun fiyat';
        // Add restaurant page
        static const String addRestaurantTitle = 'Restoran Ekle';
        static const String selectRestaurantLocationPrompt = 'Lütfen restoran konumunu seçin';
        static const String locationSuccess = 'Konum başarıyla alındı!';
        static const String locationFailedPrefix = 'Konum alınamadı:';
        static const String restaurantNameLabel = 'Restoran Adı *';
        static const String restaurantNameRequired = 'Restoran adı gerekli';
        static const String cityLabel = 'Şehir *';
        static const String cityRequired = 'Şehir gerekli';
        static const String districtLabel = 'İlçe *';
        static const String districtRequired = 'İlçe gerekli';
        static const String addressLabel = 'Adres *';
        static const String addressRequired = 'Adres gerekli';
        static const String phoneLabel = 'Telefon';
        static const String phoneHint = '0555 555 55 55';
        static const String descriptionLabel = 'Açıklama';
        static const String locationInfoLabel = 'Konum Bilgisi *';
        static const String latitudeLabel = 'Enlem';
        static const String longitudeLabel = 'Boylam';
        static const String takeCurrentLocation = 'Mevcut Konumu Al';
        static const String updateLocation = 'Konumu Güncelle';
        static const String saveRestaurant = 'Restoranı Kaydet';
        static const String myRestaurants = 'Restoranlarım';
        static const String menuProducts = 'Menü Ürünleri';
        static const String reviewsLabel = 'Yorumlar';
        static const String viewsLabel = 'Görüntülenme';
        static const String checkLocationPermissions = 'Lütfen konum izinlerini kontrol edin.';
        static const String editedSuffix = '(düzenlendi)';
        static const String delete = 'Sil';
        // Misc small UI labels
        static const String edit = 'Düzenle';
        static const String confirmDeleteReview = 'Bu yorumu silmek istediğinizden emin misiniz?';
        static const String understood = 'Anladım';
        static const String createAccount = 'Hesap Oluştur';
        static const String sessionClosed = 'Oturum kapatıldı';
        static const String alreadyHaveAccount = 'Zaten hesabınız var mı? Kayıt olun';
        static const String retryLocationPermission = 'Konum İznini Tekrar Dene';
        // Owner quick action labels
        static const String ownerActionMenuScan = 'Menü Tara';
        static const String ownerActionOcrVerify = 'OCR Doğrula';
        static const String ownerActionReports = 'Raporlar';

  // Favorites errors
  static const String favoriteAddFailed =
      'Favorilere eklenirken bir hata oluştu. Lütfen tekrar deneyin.';
  static const String favoriteRemoveFailed =
      'Favorilerden kaldırılırken bir hata oluştu. Lütfen tekrar deneyin.';

  // General errors
  static const String unknownError =
      'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';
  static const String operationFailed =
      'İşlem başarısız oldu. Lütfen tekrar deneyin.';
  static const String invalidInput = 'Geçersiz giriş. Lütfen bilgileri kontrol edin.';
  static const String permissionDenied = 'Bu işlem için gerekli izin verilmedi.';
  static const String fileUploadFailed = 'Dosya yüklenirken bir hata oluştu. Lütfen tekrar deneyin.';
  static const String fileTooLarge = 'Seçilen dosya çok büyük. Daha küçük bir dosya seçin.';
  static const String unsupportedFileType = 'Desteklenmeyen dosya türü. Lütfen farklı bir dosya seçin.';

  /// Firebase hata kodlarını kullanıcı dostu mesajlara çevirir
  static String getFirebaseAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return userNotFound;
      case 'wrong-password':
      case 'invalid-credential': // Yeni Firebase hatası (yanlış şifre veya email)
        return invalidCredentials;
      case 'email-already-in-use':
        return emailAlreadyInUse;
      case 'weak-password':
        return weakPassword;
      case 'invalid-email':
        return invalidEmail;
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış. Destek ile iletişime geçin.';
      case 'too-many-requests':
        return 'Çok fazla deneme yaptınız. Lütfen daha sonra tekrar deneyin.';
      case 'operation-not-allowed':
        return 'Bu işlem şu anda kullanılamıyor.';
      case 'network-request-failed':
        return noInternet;
      default:
        return unknownError;
    }
  }

  /// Genel hataları kullanıcı dostu mesajlara çevirir
  static String getErrorMessage(dynamic error) {
    if (error == null) return unknownError;

    final errorString = error.toString().toLowerCase();

    // Network errors
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('socket')) {
      return noInternet;
    }

    // Timeout errors
    if (errorString.contains('timeout') ||
        errorString.contains('time out')) {
      return timeout;
    }

    // Not found errors
    if (errorString.contains('not found') ||
        errorString.contains('404')) {
      return 'İstediğiniz kaynak bulunamadı.';
    }

    // Server errors
    if (errorString.contains('500') ||
        errorString.contains('server') ||
        errorString.contains('internal')) {
      return serverError;
    }

    // Permission errors
    if (errorString.contains('permission')) {
      return permissionDenied;
    }

    return unknownError;
  }

  /// Hata mesajına göre ikon döndürür
  static String getErrorIcon(String errorMessage) {
    if (errorMessage.contains('İnternet') || errorMessage.contains('bağlantı')) {
      return '📶';
    }
    if (errorMessage.contains('Konum')) {
      return '📍';
    }
    if (errorMessage.contains('Giriş') || errorMessage.contains('Kullanıcı')) {
      return '🔐';
    }
    if (errorMessage.contains('Restoran')) {
      return '🍽️';
    }
    if (errorMessage.contains('Menü')) {
      return '📋';
    }
    return '⚠️';
  }
}
