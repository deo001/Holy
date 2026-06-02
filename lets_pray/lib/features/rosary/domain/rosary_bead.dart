enum PrayerType { apostlesCreed, ourFather, hailMary, gloryBe, fatimaPrayer, hailHolyQueen }

class RosaryBead {
  final int index; // 1 to 59
  final PrayerType type;
  final String title;
  final String text;

  RosaryBead({
    required this.index,
    required this.type,
    required this.title,
    required this.text,
  });
}

class RosaryMystery {
  final String title;
  final String description;
  final List<String> decades; // The 5 mysteries in this category
  final List<String> scriptureVerses; // Scripture for each decade
  final String artworkUrl; // Placeholder path or local asset

  RosaryMystery({
    required this.title,
    required this.description,
    required this.decades,
    required this.scriptureVerses,
    required this.artworkUrl,
  });

  static Map<String, RosaryMystery> allMysteries = {
    'Joyful': RosaryMystery(
      title: 'The Joyful Mysteries',
      description: 'Meditated on Mondays and Saturdays, focusing on the incarnation and early life of Christ.',
      decades: [
        'The Annunciation of the Lord',
        'The Visitation of Mary to Elizabeth',
        'The Birth of Jesus Christ',
        'The Presentation of Jesus in the Temple',
        'The Finding of Jesus in the Temple'
      ],
      scriptureVerses: [
        '"Hail, full of grace, the Lord is with thee: blessed art thou among women." (Luke 1:28)',
        '"And whence is this to me, that the mother of my Lord should come to me?" (Luke 1:43)',
        '"And she brought forth her firstborn son, and wrapped him in swaddling clothes..." (Luke 2:7)',
        '"According as it is written in the law of the Lord: Every male opening the womb shall be called holy to the Lord." (Luke 2:23)',
        '"And it came to pass, that after three days, they found him in the temple, sitting in the midst of the doctors..." (Luke 2:46)'
      ],
      artworkUrl: 'assets/images/annunciation.png',
    ),
    'Sorrowful': RosaryMystery(
      title: 'The Sorrowful Mysteries',
      description: 'Meditated on Tuesdays and Fridays, focusing on the Passion and Death of Jesus Christ.',
      decades: [
        'The Agony of Jesus in the Garden',
        'The Scourging of Jesus at the Pillar',
        'The Crowning of Jesus with Thorns',
        'The Carrying of the Cross by Jesus',
        'The Crucifixion and Death of Jesus'
      ],
      scriptureVerses: [
        '"And being in an agony, he prayed the longer." (Luke 22:43)',
        '"Then Pilate therefore took Jesus, and scourged him." (John 19:1)',
        '"And platting a crown of thorns, they put it upon his head..." (Matthew 27:29)',
        '"And bearing his own cross, he went forth to that place which is called Calvary..." (John 19:17)',
        '"And Jesus crying with a loud voice, said: Father, into thy hands I commend my spirit." (Luke 23:46)'
      ],
      artworkUrl: 'assets/images/crucifixion.png',
    ),
    'Glorious': RosaryMystery(
      title: 'The Glorious Mysteries',
      description: 'Meditated on Wednesdays and Sundays, focusing on the Resurrection, Ascension, and glory of Heaven.',
      decades: [
        'The Resurrection of Jesus Christ',
        'The Ascension of Jesus into Heaven',
        'The Descent of the Holy Spirit at Pentecost',
        'The Assumption of Mary into Heaven',
        'The Coronation of Mary as Queen of Heaven'
      ],
      scriptureVerses: [
        '"He is not here; for he is risen, as he said." (Matthew 28:6)',
        '"And it came to pass, while he blessed them, he departed from them, and was carried up into heaven." (Luke 24:51)',
        '"And they were all filled with the Holy Ghost, and they began to speak with divers tongues..." (Acts 2:4)',
        '"An elegant sign appeared in heaven: a woman clothed with the sun, and the moon under her feet..." (Revelation 12:1)',
        '"And on her head a crown of twelve stars." (Revelation 12:1)'
      ],
      artworkUrl: 'assets/images/coronation.png',
    ),
    'Luminous': RosaryMystery(
      title: 'The Luminous Mysteries',
      description: 'Meditated on Thursdays, focusing on the public ministry and revelations of Christ.',
      decades: [
        'The Baptism of Jesus in the Jordan',
        'The Wedding at Cana',
        'The Proclamation of the Kingdom of God',
        'The Transfiguration of Jesus',
        'The Institution of the Holy Eucharist'
      ],
      scriptureVerses: [
        '"And lo, a voice from heaven, saying: This is my beloved Son, in whom I am well pleased." (Matthew 3:17)',
        '"This beginning of miracles did Jesus in Cana of Galilee; and manifested his glory..." (John 2:11)',
        '"Jesus came into Galilee, preaching the gospel of the kingdom of God, and saying: The time is fulfilled..." (Mark 1:14-15)',
        '"And he was transfigured before them. And his face did shine as the sun..." (Matthew 17:2)',
        '"And taking bread, he gave thanks, and brake; and gave to them, saying: This is my body..." (Luke 22:19)'
      ],
      artworkUrl: 'assets/images/eucharist.png',
    ),
  };

  // Helper to generate the 59 beads array
  static List<RosaryBead> generateBeadsList() {
    final List<RosaryBead> list = [];

    // 1. Apostles' Creed
    list.add(RosaryBead(
      index: 1,
      type: PrayerType.apostlesCreed,
      title: 'Apostles\' Creed',
      text: 'I believe in God, the Father Almighty, Creator of heaven and earth; and in Jesus Christ, His only Son, our Lord: Who was conceived by the Holy Spirit, born of the Virgin Mary, suffered under Pontius Pilate, was crucified, died, and was buried. He descended into hell; the third day He arose again from the dead; He ascended into heaven, and sitteth at the right hand of God the Father Almighty; from thence He shall come to judge the living and the dead. I believe in the Holy Spirit, the Holy Catholic Church, the communion of Saints, the forgiveness of sins, the resurrection of the body, and life everlasting. Amen.',
    ));

    // 2. Our Father (Intro)
    list.add(RosaryBead(
      index: 2,
      type: PrayerType.ourFather,
      title: 'Our Father',
      text: 'Our Father, Who art in heaven, hallowed be Thy name. Thy kingdom come. Thy will be done on earth as it is in heaven. Give us this day our daily bread. And forgive us our trespasses, as we forgive those who trespass against us. And lead us not into temptation, but deliver us from evil. Amen.',
    ));

    // 3. Hail Marys (Intro - 3 for Faith, Hope, and Charity)
    for (int i = 3; i <= 5; i++) {
      list.add(RosaryBead(
        index: i,
        type: PrayerType.hailMary,
        title: 'Hail Mary',
        text: 'Hail Mary, full of grace, the Lord is with thee. Blessed art thou among women, and blessed is the fruit of thy womb, Jesus. Holy Mary, Mother of God, pray for us sinners, now and at the hour of our death. Amen.',
      ));
    }

    // 6. Glory Be (Intro)
    list.add(RosaryBead(
      index: 6,
      type: PrayerType.gloryBe,
      title: 'Glory Be',
      text: 'Glory be to the Father, and to the Son, and to the Holy Spirit. As it was in the beginning, is now, and ever shall be, world without end. Amen.',
    ));

    // 7. Fatima Prayer (Intro)
    list.add(RosaryBead(
      index: 7,
      type: PrayerType.fatimaPrayer,
      title: 'O My Jesus (Fatima Prayer)',
      text: 'O my Jesus, forgive us our sins, save us from the fires of hell, lead all souls to heaven, especially those most in need of Thy mercy. Amen.',
    ));

    // Now loop for 5 decades (each has 1 Our Father, 10 Hail Marys, 1 Glory Be, 1 Fatima Prayer)
    int beadIndex = 8;
    for (int decade = 1; decade <= 5; decade++) {
      // Our Father for the Decade
      list.add(RosaryBead(
        index: beadIndex++,
        type: PrayerType.ourFather,
        title: 'Decade $decade: Our Father',
        text: 'Our Father, Who art in heaven, hallowed be Thy name. Thy kingdom come. Thy will be done on earth as it is in heaven. Give us this day our daily bread. And forgive us our trespasses, as we forgive those who trespass against us. And lead us not into temptation, but deliver us from evil. Amen.',
      ));

      // 10 Hail Marys
      for (int hm = 1; hm <= 10; hm++) {
        list.add(RosaryBead(
          index: beadIndex++,
          type: PrayerType.hailMary,
          title: 'Decade $decade: Hail Mary ($hm/10)',
          text: 'Hail Mary, full of grace, the Lord is with thee. Blessed art thou among women, and blessed is the fruit of thy womb, Jesus. Holy Mary, Mother of God, pray for us sinners, now and at the hour of our death. Amen.',
        ));
      }

      // Glory Be
      list.add(RosaryBead(
        index: beadIndex++,
        type: PrayerType.gloryBe,
        title: 'Decade $decade: Glory Be',
        text: 'Glory be to the Father, and to the Son, and to the Holy Spirit. As it was in the beginning, is now, and ever shall be, world without end. Amen.',
      ));

      // Fatima Prayer
      list.add(RosaryBead(
        index: beadIndex++,
        type: PrayerType.fatimaPrayer,
        title: 'Decade $decade: Fatima Prayer',
        text: 'O my Jesus, forgive us our sins, save us from the fires of hell, lead all souls to heaven, especially those most in need of Thy mercy. Amen.',
      ));
    }

    // Hail Holy Queen (at the end)
    list.add(RosaryBead(
      index: beadIndex++,
      type: PrayerType.hailHolyQueen,
      title: 'Hail Holy Queen (Salve Regina)',
      text: 'Hail, Holy Queen, Mother of Mercy, our life, our sweetness and our hope! To thee do we cry, poor banished children of Eve; to thee do we send up our sighs, mourning and weeping in this valley of tears. Turn then, most gracious Advocate, thine eyes of mercy toward us, and after this our exile, show unto us the blessed fruit of thy womb, Jesus. O clement, O loving, O sweet Virgin Mary! Pray for us, O Holy Mother of God, that we may be made worthy of the promises of Christ. Amen.',
    ));

    // Final Closing Prayer
    list.add(RosaryBead(
      index: beadIndex++,
      type: PrayerType.hailHolyQueen,
      title: 'Concluding Prayer',
      text: 'O God, whose only begotten Son, by His life, death, and resurrection, has purchased for us the rewards of eternal salvation, grant, we beseech Thee, that meditating upon these mysteries of the Most Holy Rosary of the Blessed Virgin Mary, we may imitate what they contain and obtain what they promise, through the same Christ our Lord. Amen.',
    ));

    return list;
  }
}
