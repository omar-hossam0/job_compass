import 'package:flutter/material.dart';

class JobsData {
  static const List<Map<String, dynamic>> allJobs = [
    // Google
    {
      'id': 'google_1',
      'company': 'Google',
      'location': 'Mountain View, California',
      'title': 'Senior Product Designer',
      'type': 'Full Time',
      'salary': '\$11K - \$15K',
      'logo': 0xf101, // Google logo placeholder
      'logoColor': 0xff4285F4,
    },
    {
      'id': 'google_2',
      'company': 'Google',
      'location': 'San Francisco, California',
      'title': 'UX/UI Designer',
      'type': 'Full Time',
      'salary': '\$9K - \$13K',
      'logo': 0xf101,
      'logoColor': 0xff4285F4,
    },
    {
      'id': 'google_3',
      'company': 'Google',
      'location': 'London, UK',
      'title': 'Lead Designer',
      'type': 'Full Time',
      'salary': '\$13K - \$18K',
      'logo': 0xf101,
      'logoColor': 0xff4285F4,
    },
    // Apple
    {
      'id': 'apple_1',
      'company': 'Apple',
      'location': 'Cupertino, California',
      'title': 'Senior UX Designer',
      'type': 'Full Time',
      'salary': '\$12K - \$16K',
      'logo': 0xf102, // Apple logo placeholder
      'logoColor': 0xff000000,
    },
    {
      'id': 'apple_2',
      'company': 'Apple',
      'location': 'San Francisco, California',
      'title': 'Interaction Designer',
      'type': 'Full Time',
      'salary': '\$11K - \$15K',
      'logo': 0xf102,
      'logoColor': 0xff000000,
    },
    {
      'id': 'apple_3',
      'company': 'Apple',
      'location': 'Berlin, Germany',
      'title': 'Product Designer',
      'type': 'Full Time',
      'salary': '\$10K - \$14K',
      'logo': 0xf102,
      'logoColor': 0xff000000,
    },
    // Microsoft
    {
      'id': 'microsoft_1',
      'company': 'Microsoft',
      'location': 'Redmond, Washington',
      'title': 'Senior Designer',
      'type': 'Full Time',
      'salary': '\$9K - \$13K',
      'logo': 0xf103, // Microsoft logo placeholder
      'logoColor': 0xff00A4EF,
    },
    {
      'id': 'microsoft_2',
      'company': 'Microsoft',
      'location': 'Seattle, Washington',
      'title': 'Design Researcher',
      'type': 'Full Time',
      'salary': '\$9K - \$13K',
      'logo': 0xf103,
      'logoColor': 0xff00A4EF,
    },
    {
      'id': 'microsoft_3',
      'company': 'Microsoft',
      'location': 'Toronto, Canada',
      'title': 'UI Designer',
      'type': 'Full Time',
      'salary': '\$8K - \$12K',
      'logo': 0xf103,
      'logoColor': 0xff00A4EF,
    },
    // Amazon
    {
      'id': 'amazon_1',
      'company': 'Amazon',
      'location': 'Seattle, Washington',
      'title': 'Senior UX Designer',
      'type': 'Full Time',
      'salary': '\$13K - \$17K',
      'logo': 0xf104, // Amazon logo placeholder
      'logoColor': 0xffFF9900,
    },
    {
      'id': 'amazon_2',
      'company': 'Amazon',
      'location': 'Austin, Texas',
      'title': 'Product Designer',
      'type': 'Full Time',
      'salary': '\$11K - \$15K',
      'logo': 0xf104,
      'logoColor': 0xffFF9900,
    },
    // Meta
    {
      'id': 'meta_1',
      'company': 'Meta',
      'location': 'Menlo Park, California',
      'title': 'UI/UX Designer',
      'type': 'Full Time',
      'salary': '\$11K - \$15K',
      'logo': 0xf105, // Meta logo placeholder
      'logoColor': 0xff1877F2,
    },
    {
      'id': 'meta_2',
      'company': 'Meta',
      'location': 'Dublin, Ireland',
      'title': 'Design Strategist',
      'type': 'Full Time',
      'salary': '\$11K - \$15K',
      'logo': 0xf105,
      'logoColor': 0xff1877F2,
    },
    // Netflix
    {
      'id': 'netflix_1',
      'company': 'Netflix',
      'location': 'Los Gatos, California',
      'title': 'Product Designer',
      'type': 'Full Time',
      'salary': '\$12K - \$16K',
      'logo': 0xf106, // Netflix logo placeholder
      'logoColor': 0xffE50914,
    },
    {
      'id': 'netflix_2',
      'company': 'Netflix',
      'location': 'Tokyo, Japan',
      'title': 'UX Designer',
      'type': 'Full Time',
      'salary': '\$10K - \$14K',
      'logo': 0xf106,
      'logoColor': 0xffE50914,
    },
    // Tesla
    {
      'id': 'tesla_1',
      'company': 'Tesla',
      'location': 'Palo Alto, California',
      'title': 'Designer - Automotive UI',
      'type': 'Full Time',
      'salary': '\$11K - \$15K',
      'logo': 0xf107, // Tesla logo placeholder
      'logoColor': 0xffCC0000,
    },
    {
      'id': 'tesla_2',
      'company': 'Tesla',
      'location': 'Austin, Texas',
      'title': 'Product Design Engineer',
      'type': 'Full Time',
      'salary': '\$12K - \$16K',
      'logo': 0xf107,
      'logoColor': 0xffCC0000,
    },
    // IBM
    {
      'id': 'ibm_1',
      'company': 'IBM',
      'location': 'Armonk, New York',
      'title': 'Senior Design Consultant',
      'type': 'Full Time',
      'salary': '\$10K - \$14K',
      'logo': 0xf108, // IBM logo placeholder
      'logoColor': 0xff0F62FE,
    },
    {
      'id': 'ibm_2',
      'company': 'IBM',
      'location': 'Austin, Texas',
      'title': 'UX/UI Specialist',
      'type': 'Full Time',
      'salary': '\$9K - \$13K',
      'logo': 0xf108,
      'logoColor': 0xff0F62FE,
    },
    // LinkedIn
    {
      'id': 'linkedin_1',
      'company': 'LinkedIn',
      'location': 'Sunnyvale, California',
      'title': 'Senior Product Designer',
      'type': 'Full Time',
      'salary': '\$12K - \$16K',
      'logo': 0xf109, // LinkedIn logo placeholder
      'logoColor': 0xff0A66C2,
    },
    {
      'id': 'linkedin_2',
      'company': 'LinkedIn',
      'location': 'San Francisco, California',
      'title': 'Design Manager',
      'type': 'Full Time',
      'salary': '\$13K - \$17K',
      'logo': 0xf109,
      'logoColor': 0xff0A66C2,
    },
    // Adobe
    {
      'id': 'adobe_1',
      'company': 'Adobe',
      'location': 'San Jose, California',
      'title': 'Product Designer',
      'type': 'Full Time',
      'salary': '\$11K - \$15K',
      'logo': 0xf10a, // Adobe logo placeholder
      'logoColor': 0xffDA1F26,
    },
    {
      'id': 'adobe_2',
      'company': 'Adobe',
      'location': 'Edinburgh, Scotland',
      'title': 'UX Designer',
      'type': 'Full Time',
      'salary': '\$10K - \$14K',
      'logo': 0xf10a,
      'logoColor': 0xffDA1F26,
    },
    // Spotify
    {
      'id': 'spotify_1',
      'company': 'Spotify',
      'location': 'Stockholm, Sweden',
      'title': 'Design Lead',
      'type': 'Full Time',
      'salary': '\$12K - \$16K',
      'logo': 0xf10b, // Spotify logo placeholder
      'logoColor': 0xff1DB954,
    },
    {
      'id': 'spotify_2',
      'company': 'Spotify',
      'location': 'New York, USA',
      'title': 'Product Designer',
      'type': 'Full Time',
      'salary': '\$11K - \$15K',
      'logo': 0xf10b,
      'logoColor': 0xff1DB954,
    },
    // Uber
    {
      'id': 'uber_1',
      'company': 'Uber',
      'location': 'San Francisco, California',
      'title': 'Senior UX Designer',
      'type': 'Full Time',
      'salary': '\$12K - \$16K',
      'logo': 0xf10c, // Uber logo placeholder
      'logoColor': 0xff000000,
    },
    {
      'id': 'uber_2',
      'company': 'Uber',
      'location': 'Berlin, Germany',
      'title': 'Product Designer',
      'type': 'Full Time',
      'salary': '\$10K - \$14K',
      'logo': 0xf10c,
      'logoColor': 0xff000000,
    },
    // Airbnb
    {
      'id': 'airbnb_1',
      'company': 'Airbnb',
      'location': 'San Francisco, California',
      'title': 'Product Designer',
      'type': 'Full Time',
      'salary': '\$12K - \$16K',
      'logo': 0xf10d, // Airbnb logo placeholder
      'logoColor': 0xffFF5A5F,
    },
    {
      'id': 'airbnb_2',
      'company': 'Airbnb',
      'location': 'Paris, France',
      'title': 'Design Researcher',
      'type': 'Full Time',
      'salary': '\$10K - \$14K',
      'logo': 0xf10d,
      'logoColor': 0xffFF5A5F,
    },
    // Slack
    {
      'id': 'slack_1',
      'company': 'Slack',
      'location': 'San Francisco, California',
      'title': 'Senior Product Designer',
      'type': 'Full Time',
      'salary': '\$11K - \$15K',
      'logo': 0xf10e, // Slack logo placeholder
      'logoColor': 0xffE01E5A,
    },
    {
      'id': 'slack_2',
      'company': 'Slack',
      'location': 'Toronto, Canada',
      'title': 'UX Designer',
      'type': 'Full Time',
      'salary': '\$10K - \$14K',
      'logo': 0xf10e,
      'logoColor': 0xffE01E5A,
    },
  ];

  // Helper function to get company logo icon
  static IconData getCompanyLogo(String company) {
    switch (company) {
      case 'Google':
        return Icons.g_mobiledata;
      case 'Apple':
        return Icons.apple;
      case 'Microsoft':
        return Icons.window;
      case 'Amazon':
        return Icons.shopping_cart;
      case 'Meta':
        return Icons.facebook;
      case 'Netflix':
        return Icons.play_arrow;
      case 'Tesla':
        return Icons.electric_car;
      case 'IBM':
        return Icons.computer;
      case 'LinkedIn':
        return Icons.business;
      case 'Adobe':
        return Icons.brush;
      case 'Spotify':
        return Icons.music_note;
      case 'Uber':
        return Icons.directions_car;
      case 'Airbnb':
        return Icons.home;
      case 'Slack':
        return Icons.chat;
      default:
        return Icons.business_center;
    }
  }

  // Helper function to get company logo color
  static Color getCompanyColor(String company) {
    switch (company) {
      case 'Google':
        return const Color(0xff4285F4);
      case 'Apple':
        return const Color(0xff000000);
      case 'Microsoft':
        return const Color(0xff00A4EF);
      case 'Amazon':
        return const Color(0xffFF9900);
      case 'Meta':
        return const Color(0xff1877F2);
      case 'Netflix':
        return const Color(0xffE50914);
      case 'Tesla':
        return const Color(0xffCC0000);
      case 'IBM':
        return const Color(0xff0F62FE);
      case 'LinkedIn':
        return const Color(0xff0A66C2);
      case 'Adobe':
        return const Color(0xffDA1F26);
      case 'Spotify':
        return const Color(0xff1DB954);
      case 'Uber':
        return const Color(0xff000000);
      case 'Airbnb':
        return const Color(0xffFF5A5F);
      case 'Slack':
        return const Color(0xffE01E5A);
      default:
        return const Color(0xff3F6CDF);
    }
  }
}
