class ApiConstants {
  // Base URL sesuai kontrak API soal UKK
  static const String baseUrl = 'https://learn.smktelkom-mlg.sch.id/bank_sampah/';

  // === App Maker ===
  static const String makerRegister = 'api/v1/maker/register';
  static const String makerLogin    = 'api/v1/maker/login';
  static const String makerProfil   = 'api/v1/maker/profile';
  static const String makerCheckKey = 'api/v1/maker/check-key';

  // === Auth User ===
  static const String authNasabahRegister = 'api/v1/auth/nasabah/register';
  static const String authAdminRegister   = 'api/v1/auth/admin/register';
  static const String authNasabahLogin    = 'api/v1/auth/nasabah/login';
  static const String authAdminLogin      = 'api/v1/auth/admin/login';
  static const String authLogin           = 'api/v1/auth/login';
  static const String authMe              = 'api/v1/auth/me';
  static const String authNasabahProfile  = 'api/v1/auth/nasabah/profile';

  // === Admin – CRUD Nasabah ===
  static const String adminNasabah = 'api/v1/admin/nasabah';

  // === Kategori Sampah ===
  static const String kategoriSampah = 'api/v1/kategori-sampah';

  // === Setor Sampah ===
  static const String setorPengajuan  = 'api/v1/setor-sampah/pengajuan';
  static const String setorMySetor    = 'api/v1/setor-sampah/my-setor';
  static const String setorAdminList  = 'api/v1/setor-sampah/admin/list';
  static const String setorDetail     = 'api/v1/setor-sampah';   // + /{id}
  static const String setorAdminVerify = 'api/v1/setor-sampah/admin/verify'; // + /{id}

  // === Hadiah ===
  static const String hadiah = 'api/v1/hadiah';

  // === Penukaran Poin ===
  static const String penukaranTukar       = 'api/v1/penukaran-poin/tukar';
  static const String penukaranMyPenukaran = 'api/v1/penukaran-poin/my-penukaran';
  static const String penukaranAdminList   = 'api/v1/penukaran-poin/admin/list';
  static const String penukaranAdminStatus = 'api/v1/penukaran-poin/admin/status'; // + /{id}
  static const String penukaranNota        = 'api/v1/penukaran-poin/nota';          // + /{id}

  // === Rekapitulasi ===
  static const String rekapitulasiBulanan = 'api/v1/rekapitulasi/bulanan';

  // === Dashboard ===
  static const String dashboardSummary = 'api/v1/dashboard/summary';
  static const String dashboardStats   = 'api/v1/dashboard/stats';

  // === Seed ===
  static const String seed = 'api/v1/seed';
}
