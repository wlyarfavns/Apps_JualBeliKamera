import '../models/product_model.dart';

class DummyData {
  static List<ProductModel> products = [
    ProductModel(
      id: '1',
      name: 'Sony Alpha 7R V Body Only',
      brand: 'SONY',
      category: 'Mirrorless',
      price: 64999000,
      imageUrl: 'https://images.unsplash.com/photo-1616440347437-b1c73416efc2?auto=format&fit=crop&w=600&q=80',
      description: 'Generasi terbaru dengan AI processing unit untuk autofokus berbasis pengenalan subjek tingkat lanjut, dipadukan dengan sensor resolusi ultra-tinggi 61.0MP untuk detail yang belum pernah ada sebelumnya.',
      features: [
        '61.0MP Full-Frame',
        'BIONZ XR Engine',
        '8K 24p / 4K 60p',
        '8-Step IBIS'
      ],
      specs: {
        'Tipe Sensor': '35mm full frame Exmor R CMOS',
        'Sensitivitas ISO': '100-32000 (Exp: 50-102400)',
        'Titik Fokus': '693 phase-detection points',
        'Layar Monitor': '3.2" 4-axis multi-angle LCD'
      },
      rating: 4.9,
      reviewsCount: 142,
      reviewUser: 'Alex Mercer',
      reviewText: 'Autofokus berbasis AI-nya benar-benar mengubah cara saya memotret. Sangat presisi meski kondisi cahaya kurang ideal.'
    ),
    ProductModel(
      id: '2',
      name: 'Sony Alpha A7 IV Body Only',
      brand: 'SONY',
      category: 'Mirrorless',
      price: 38999000,
      imageUrl: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=600&q=80',
      description: 'Kamera hybrid andalan dengan performa gambar diam luar biasa dan perekaman video 4K 60p berkualitas tinggi, ditenagai sensor Exmor R 33MP.',
      features: [
        '33MP Full-Frame',
        'BIONZ XR Engine',
        '4K 60p Video',
        'Real-time Eye AF'
      ],
      specs: {
        'Tipe Sensor': '35mm full frame Exmor R CMOS',
        'Sensitivitas ISO': '100-51200 (Exp: 50-204800)',
        'Titik Fokus': '759 phase-detection points',
        'Layar Monitor': '3.0" vari-angle touchscreen'
      },
      rating: 4.8,
      reviewsCount: 98,
      reviewUser: 'Rian F.',
      reviewText: 'Kamera hybrid terbaik untuk harganya saat ini. Fitur video sangat mumpuni!'
    ),
    ProductModel(
      id: '3',
      name: 'Canon EOS R6 Mark II Body',
      brand: 'CANON',
      category: 'Mirrorless',
      price: 42500000,
      imageUrl: 'https://images.unsplash.com/photo-1502982720700-bfff97f2ecac?auto=format&fit=crop&w=600&q=80',
      description: 'Menawarkan kecepatan luar biasa hingga 40 fps, autofokus Dual Pixel CMOS AF II yang legendaris, serta perekaman video internal 4K 60p tanpa crop.',
      features: [
        '24.2MP Full-Frame',
        'DIGIC X Image Processor',
        '40 fps Electronic Shutter',
        '4K 60p Video (Uncropped)'
      ],
      specs: {
        'Tipe Sensor': 'Full-frame CMOS sensor',
        'Sensitivitas ISO': '100-102400 (Exp: 50-204800)',
        'Titik Fokus': '1053 autofocus zones',
        'Layar Monitor': '3.0" vari-angle touchscreen'
      },
      rating: 4.7,
      reviewsCount: 85,
      reviewUser: 'Hendra W.',
      reviewText: 'Sangat cepat untuk memotret aksi olahraga dan satwa liar. Tracking autofokus Canon luar biasa.'
    ),
    ProductModel(
      id: '4',
      name: 'Sony FE 50mm f/1.2 GM Lens',
      brand: 'SONY',
      category: 'Lensa',
      price: 32999000,
      imageUrl: 'https://images.unsplash.com/photo-1617005082133-548c4dd27f35?auto=format&fit=crop&w=600&q=80',
      description: 'Lensa prime legendaris G Master f/1.2 dengan bokeh luar biasa halus dan ketajaman tingkat tinggi dari sudut ke sudut, ideal untuk potret profesional.',
      features: [
        'Aperture Maksimum f/1.2',
        'Tiga Elemen XA (Extreme Aspherical)',
        'Empat Motor Linear XD',
        'Lapisan Nano AR II'
      ],
      specs: {
        'Jarak Fokus Min': '0.4 m (1.32 ft)',
        'Rasio Pembesaran': '0.17x',
        'Diameter Filter': '72 mm',
        'Berat Lensa': '778 g'
      },
      rating: 4.9,
      reviewsCount: 110,
      reviewUser: 'Siti Rahma',
      reviewText: 'Bokeh-nya sangat creamy dan fokusnya instan. Sangat berharga untuk fotografi komersial!'
    ),
    ProductModel(
      id: '5',
      name: 'Sony FE 24-70mm f/2.8 GM II',
      brand: 'SONY',
      category: 'Lensa',
      price: 32500000,
      imageUrl: 'https://images.unsplash.com/photo-1607462109225-6b64ae2dd3cb?auto=format&fit=crop&w=600&q=80',
      description: 'Lensa zoom standar teringan dan terkecil di kelasnya dengan aperture konstan f/2.8. Menawarkan performa optik murni dan autofokus super cepat.',
      features: [
        'Aperture Konstan f/2.8',
        'Desain Lebih Ringan 20%',
        'Empat Motor Linear XD',
        'Kontrol Aperture De-click'
      ],
      specs: {
        'Jarak Fokus Min': '0.21 - 0.30 m',
        'Rasio Pembesaran': '0.32x',
        'Diameter Filter': '82 mm',
        'Berat Lensa': '695 g'
      },
      rating: 4.8,
      reviewsCount: 74,
      reviewUser: 'Dian K.',
      reviewText: 'Lensa andalan sehari-hari saya. Ringan, tajam, dan serbaguna.'
    ),
    ProductModel(
      id: '6',
      name: 'Peak Design Travel Tripod Carbon',
      brand: 'PEAK DESIGN',
      category: 'Aksesoris',
      price: 9800000,
      imageUrl: 'https://images.unsplash.com/photo-1620641788421-7a1c342ea42e?auto=format&fit=crop&w=600&q=80',
      description: 'Tripod perjalanan serat karbon super ringkas dengan kestabilan sekelas tripod studio besar. Dapat dilipat sangat tipis seukuran botol air.',
      features: [
        'Bahan Serat Karbon Premium',
        'Tinggi Maks 152.4 cm',
        'Kapasitas Beban 9.1 kg',
        'Dudukan Ponsel Terintegrasi'
      ],
      specs: {
        'Tinggi Lipat': '39.1 cm',
        'Berat Tripod': '1.27 kg',
        'Kunci Kaki': 'Cam levers',
        'Bahan': 'Carbon fiber'
      },
      rating: 4.6,
      reviewsCount: 52,
      reviewUser: 'Adi Nugroho',
      reviewText: 'Sangat ringkas dan mudah dibawa ke mana saja. Sangat kokoh menahan kamera full frame berat.'
    ),
    ProductModel(
      id: '7',
      name: 'Fujifilm X-T5 Mirrorless Camera',
      brand: 'FUJIFILM',
      category: 'Mirrorless',
      price: 28999000,
      imageUrl: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=600&q=80',
      description: 'Menghadirkan pesona retro dengan sensor X-Trans CMOS 5 HR 40.2MP beresolusi tinggi dan prosesor X-Processor 5 yang bertenaga.',
      features: [
        '40.2MP APS-C X-Trans 5',
        '7-Stop In-Body Image Stabilization',
        'Perekaman Video 6.2K 30p',
        'Layar Tilting 3 Arah'
      ],
      specs: {
        'Tipe Sensor': 'APS-C X-Trans CMOS 5 HR',
        'Sensitivitas ISO': '125-12800 (Exp: 64-51200)',
        'Titik Fokus': '425 Intelligent Hybrid AF',
        'Layar Monitor': '3.0" 3-way tilting LCD'
      },
      rating: 4.8,
      reviewsCount: 66,
      reviewUser: 'Gita P.',
      reviewText: 'Warna simulasi film Fujifilm selalu luar biasa. Sensor baru 40MP sangat tajam.'
    ),
  ];
}
