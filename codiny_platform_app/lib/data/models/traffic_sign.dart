class TrafficSign {
  final String id;
  final String name;
  final String imagePath;
  final String category;
  final String description;
  final String arabicName;

  TrafficSign({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.category,
    required this.description,
    required this.arabicName,
  });
}

class TrafficSignsData {
  static List<TrafficSign> getAllSigns() {
    return [
      // Speed Signs
      TrafficSign(
        id: '1',
        name: '30 km/h',
        arabicName: 'حد السرعة 30',
        imagePath: 'assets/traffic_signs/30.png',
        category: 'speed',
        description: 'الحد الأقصى للسرعة 30 كم/ساعة',
      ),
      TrafficSign(
        id: '2',
        name: '50 km/h',
        arabicName: 'حد السرعة 50',
        imagePath: 'assets/traffic_signs/50.png',
        category: 'speed',
        description: 'الحد الأقصى للسرعة 50 كم/ساعة',
      ),
      TrafficSign(
        id: '3',
        name: '70 km/h',
        arabicName: 'حد السرعة 70',
        imagePath: 'assets/traffic_signs/70.png',
        category: 'speed',
        description: 'الحد الأقصى للسرعة 70 كم/ساعة',
      ),

      // Warning Signs
      TrafficSign(
        id: '4',
        name: 'Danger',
        arabicName: 'خطر',
        imagePath: 'assets/traffic_signs/Danger.png',
        category: 'warning',
        description: 'إشارة تحذيرية - خطر',
      ),
      TrafficSign(
        id: '5',
        name: 'Slippery Road',
        arabicName: 'طريق زلق',
        imagePath: 'assets/traffic_signs/Slipy.png',
        category: 'warning',
        description: 'احذر - طريق زلق',
      ),
      TrafficSign(
        id: '6',
        name: 'Road Work',
        arabicName: 'أشغال على الطريق',
        imagePath: 'assets/traffic_signs/Work.png',
        category: 'warning',
        description: 'أشغال جارية على الطريق',
      ),
      TrafficSign(
        id: '7',
        name: 'Children',
        arabicName: 'احذر الأطفال',
        imagePath: 'assets/traffic_signs/Kids.png',
        category: 'warning',
        description: 'احذر - منطقة عبور أطفال',
      ),
      TrafficSign(
        id: '8',
        name: 'Pedestrians',
        arabicName: 'المشاة',
        imagePath: 'assets/traffic_signs/Walker.png',
        category: 'warning',
        description: 'احذر - معبر مشاة',
      ),
      TrafficSign(
        id: '9',
        name: 'Animals',
        arabicName: 'مطبّات بالطريق',
        imagePath: 'assets/traffic_signs/Donkey.png',
        category: 'warning',
        description: 'احذر - مطبّات بالطريق',
      ),
      TrafficSign(
        id: '10',
        name: 'Zigzag Road',
        arabicName: 'طريق متعرج',
        imagePath: 'assets/traffic_signs/ZigZag.png',
        category: 'warning',
        description: 'احذر - طريق متعرج',
      ),

      // Prohibition Signs
      TrafficSign(
        id: '11',
        name: 'No Entry',
        arabicName: 'ممنوع الدخول',
        imagePath: 'assets/traffic_signs/NoPass.png',
        category: 'prohibition',
        description: 'ممنوع الدخول',
      ),
      TrafficSign(
        id: '12',
        name: 'No Left Turn',
        arabicName: 'ممنوع الالتفاف يساراً',
        imagePath: 'assets/traffic_signs/NoLeft.png',
        category: 'prohibition',
        description: 'ممنوع الالتفاف إلى اليسار',
      ),
      TrafficSign(
        id: '13',
        name: 'No Right Turn',
        arabicName: 'ممنوع الالتفاف يميناً',
        imagePath: 'assets/traffic_signs/NoRight.png',
        category: 'prohibition',
        description: 'ممنوع الالتفاف إلى اليمين',
      ),
      TrafficSign(
        id: '14',
        name: 'No U-Turn',
        arabicName: 'ممنوع الرجوع',
        imagePath: 'assets/traffic_signs/NoReturn.png',
        category: 'prohibition',
        description: 'ممنوع الرجوع للخلف',
      ),
      TrafficSign(
        id: '15',
        name: 'No Stopping',
        arabicName: 'ممنوع التوقف',
        imagePath: 'assets/traffic_signs/NoStop.png',
        category: 'prohibition',
        description: 'ممنوع التوقف',
      ),
      TrafficSign(
        id: '16',
        name: 'No Parking',
        arabicName: 'ممنوع الوقوف والانتظار',
        imagePath: 'assets/traffic_signs/NoStopAndWait.png',
        category: 'prohibition',
        description: 'ممنوع الوقوف والانتظار',
      ),
      TrafficSign(
        id: '17',
        name: 'No Bicycles',
        arabicName: 'ممنوع الدراجات',
        imagePath: 'assets/traffic_signs/NoBike.png',
        category: 'prohibition',
        description: 'ممنوع مرور الدراجات',
      ),
      TrafficSign(
        id: '18',
        name: 'No Trucks',
        arabicName: 'ممنوع الشاحنات',
        imagePath: 'assets/traffic_signs/NoTruck.png',
        category: 'prohibition',
        description: 'ممنوع مرور الشاحنات',
      ),
      TrafficSign(
        id: '19',
        name: 'No Priority',
        arabicName: 'ممنوع الأولوية',
        imagePath: 'assets/traffic_signs/NoPeriority.png',
        category: 'prohibition',
        description: 'لا أولوية في المرور',
      ),

      // Mandatory Signs
      TrafficSign(
        id: '20',
        name: 'Turn Left',
        arabicName: 'التفت يساراً',
        imagePath: 'assets/traffic_signs/Left.png',
        category: 'mandatory',
        description: 'يجب الالتفاف إلى اليسار',
      ),
      TrafficSign(
        id: '21',
        name: 'Turn Right',
        arabicName: 'التفت يميناً',
        imagePath: 'assets/traffic_signs/Right.png',
        category: 'mandatory',
        description: 'يجب الالتفاف إلى اليمين',
      ),
      TrafficSign(
        id: '22',
        name: 'Go Straight',
        arabicName: 'سر مستقيماً',
        imagePath: 'assets/traffic_signs/UP.png',
        category: 'mandatory',
        description: 'يجب السير مستقيماً',
      ),
      TrafficSign(
        id: '23',
        name: 'Must Stop',
        arabicName: 'قف',
        imagePath: 'assets/traffic_signs/Stop.png',
        category: 'mandatory',
        description: 'يجب التوقف',
      ),
      TrafficSign(
        id: '24',
        name: 'Mandatory Direction',
        arabicName: 'اتجاه إجباري',
        imagePath: 'assets/traffic_signs/Must.png',
        category: 'mandatory',
        description: 'اتجاه إجباري',
      ),
      TrafficSign(
        id: '25',
        name: 'Bicycles Only',
        arabicName: 'ممر الدراجات',
        imagePath: 'assets/traffic_signs/Bike.png',
        category: 'mandatory',
        description: 'ممر مخصص للدراجات فقط',
      ),

      // Priority Signs
      TrafficSign(
        id: '26',
        name: 'Priority Road',
        arabicName: 'طريق ذو أولوية',
        imagePath: 'assets/traffic_signs/RoadPeriority.png',
        category: 'priority',
        description: 'طريق ذو أولوية في المرور',
      ),
      TrafficSign(
        id: '27',
        name: 'Give Way',
        arabicName: 'أعط الأولوية',
        imagePath: 'assets/traffic_signs/Periority.png',
        category: 'priority',
        description: 'أعط الأولوية للآخرين',
      ),

      // Information Signs
      TrafficSign(
        id: '28',
        name: 'Free Zone',
        arabicName: 'منطقة حرة',
        imagePath: 'assets/traffic_signs/Free.png',
        category: 'information',
        description: 'منطقة حرة',
      ),
      TrafficSign(
        id: '29',
        name: 'Down',
        arabicName: 'منحدر',
        imagePath: 'assets/traffic_signs/Down.png',
        category: 'information',
        description: 'منحدر',
      ),
    ];
  }

  static List<String> getCategories() {
    return [
      'الكل',
      'السرعة',
      'تحذيرية',
      'منع',
      'إلزامية',
      'أولوية',
      'معلوماتية',
    ];
  }

  static String getCategoryInEnglish(String arabicCategory) {
    switch (arabicCategory) {
      case 'السرعة':
        return 'speed';
      case 'تحذيرية':
        return 'warning';
      case 'منع':
        return 'prohibition';
      case 'إلزامية':
        return 'mandatory';
      case 'أولوية':
        return 'priority';
      case 'معلوماتية':
        return 'information';
      default:
        return 'all';
    }
  }
}
