import os
from dotenv import load_dotenv

# dotenv ile .env dosyasını yüklemeye çalışır.
# Dosya yoksa hata vermez, sessizce geçer.
try:
    load_dotenv(".env")
except Exception as e:
    print(
        f"Uyarı: .env dosyası bulunamadı veya yüklenirken bir hata oluştu. Lütfen dosya yolunu kontrol edin. Hata: {e}")

# Hata ayıklama için yüklenen ortam değişkenlerinin değerlerini yazdırın.
print("-" * 20)
print("Ortam Değişkenleri Yükleniyor...")
print(f"DB_HOST: {os.getenv('DB_HOST')}")
print(f"DB_USER: {os.getenv('DB_USER')}")
print(f"DB_PASSWORD: {os.getenv('DB_PASSWORD')}")
print(f"DB_DATABASE: {os.getenv('DB_DATABASE')}")
print("-" * 20)


class Settings:
    """
    Uygulama ayarlarını ortam değişkenlerinden okuyan sınıf.
    Değerler bulunamazsa varsayılan değerler kullanılır.
    """
    DB_HOST: str = os.getenv("DB_HOST", "localhost")
    DB_USER: str = os.getenv("DB_USER", "root")

    # Parola için varsayılan değer atamak tehlikeli olabilir, bu yüzden None olarak bırakılır.
    # Eğer parola bulunamazsa, uygulama başlangıçta hata verecektir.
    DB_PASSWORD: str = os.getenv("DB_PASSWORD")

    DB_DATABASE: str = os.getenv("DB_DATABASE")

    # Ayarların doğru yüklendiğini kontrol etmek için bir doğrulama fonksiyonu ekledik.
    def validate(self):
        """
        Gerekli ortam değişkenlerinin mevcut olduğunu kontrol eder.
        """
        if not self.DB_PASSWORD:
            raise ValueError("DB_PASSWORD ortam değişkeni ayarlanmamış.")
        if not self.DB_DATABASE:
            raise ValueError("DB_DATABASE ortam değişkeni ayarlanmamış.")


settings = Settings()
settings.validate()
