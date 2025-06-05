// therapy_area.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_state.dart'; // ApplicationState import

// 아이콘 이름을 IconData로 매핑하는 함수 (개선 필요)
IconData getIconDataFromString(String iconName) {
  // 간단한 예시입니다. 실제로는 더 많은 아이콘을 매핑하거나 다른 방식을 사용해야 합니다.
  switch (iconName.toLowerCase()) {
    case 'child_care':
      return Icons.child_care;
    case 'school':
      return Icons.school;
    case 'favorite':
      return Icons.favorite;
    case 'people':
      return Icons.people;
    case 'healing':
      return Icons.healing;
    case 'spa': // 번아웃/트라우마에 대한 아이콘 예시
      return Icons.spa; // 또는 Icons.psychology, Icons.self_improvement 등
    default:
      return Icons.help_outline; // 기본 아이콘
  }
}

class TherapyPage extends StatefulWidget {
  const TherapyPage({super.key});

  @override
  State<TherapyPage> createState() => _TherapyPageState();
}

class _TherapyPageState extends State<TherapyPage> {
  // 카드 탭 시 확대/축소 효과를 위한 상태
  String? _selectedCardId;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<ApplicationState>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('상담 분야 안내'),
        backgroundColor: const Color(0xFFE8F5E9), // 연한 녹색 계열
      ),
      body: Stack(
        children: [
          // 1. 숲 테마 배경 (은은하게)
          Positioned.fill(
            child: Opacity(
              opacity: 0.1, // 투명도 조절
              child: Image.asset(
                'assets/enviroment.png', // TODO: 실제 이미지 경로로 변경
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 2. Firestore 데이터 연동하여 카드 목록 표시
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: appState.getTherapyAreas(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('등록된 상담 분야가 아직 없습니다.'),
                );
              }

              final therapyDocs = snapshot.data!.docs;

              // ListView.builder 또는 GridView.builder 선택
              // 여기서는 ListView.builder를 사용합니다.
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: therapyDocs.length,
                itemBuilder: (context, index) {
                  final doc = therapyDocs[index];
                  final data = doc.data();
                  final cardId = doc.id; // Firestore 문서 ID

                  // Firestore에서 가져온 데이터 사용
                  String title = data['title'] ?? '제목 없음';
                  String description = data['description'] ?? '설명 없음';
                  String iconName = data['iconName'] ?? 'help_outline';
                  // String? imagePath = data['imagePath']; // 카드별 배경 이미지 (선택 사항)

                  return _buildTherapyCard(
                    context: context,
                    id: cardId,
                    title: title,
                    description: description,
                    iconData: getIconDataFromString(iconName),
                    // cardImagePath: imagePath, // 카드별 이미지 경로 전달
                    isSelected: _selectedCardId == cardId,
                    onTap: () {
                      setState(() {
                        if (_selectedCardId == cardId) {
                          _selectedCardId = null; // 다시 탭하면 원래 크기로
                        } else {
                          _selectedCardId = cardId; // 탭한 카드 선택
                        }
                      });
                      // TODO: 카드 탭 시 상세 페이지로 이동하거나 추가 정보 표시 로직
                      print('$title 카드 탭됨');
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      // TODO: 관리자용 카드 추가/수정/삭제 버튼 (floatingActionButton 등 활용, app_state.user가 관리자일 때만 보이도록)
    );
  }

  Widget _buildTherapyCard({
    required BuildContext context,
    required String id,
    required String title,
    required String description,
    required IconData iconData,
    String? cardImagePath, // 카드별 배경 이미지 (선택적)
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final cardColor = Colors.green.shade50.withOpacity(0.85); // 숲 테마 카드 색상
    final splashColor = theme.primaryColor.withOpacity(0.2);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(isSelected ? 1.03 : 1.0), // 선택 시 살짝 확대
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Card(
          elevation: isSelected ? 8.0 : 4.0, // 선택 시 그림자 강조
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: BorderSide(
              color: isSelected ? theme.primaryColor : Colors.transparent,
              width: isSelected ? 2.0 : 0.0,
            )
          ),
          color: cardColor,
          // 만약 카드별 이미지가 있다면 ClipRRect와 Stack을 사용해 배경으로 깔 수 있습니다.
          // child: cardImagePath != null && cardImagePath.isNotEmpty
          // ? ClipRRect(
          //     borderRadius: BorderRadius.circular(15.0),
          //     child: Stack(
          //       children: [
          //         Positioned.fill(
          //           child: Opacity(
          //             opacity: 0.3, // 이미지 투명도
          //             child: Image.asset(cardImagePath, fit: BoxFit.cover),
          //           ),
          //         ),
          //         _buildCardContent(title, description, iconData, theme, splashColor),
          //       ],
          //     ),
          //   )
          // : _buildCardContent(title, description, iconData, theme, splashColor),
          child: _buildCardContent(title, description, iconData, theme, splashColor),
        ),
      ),
    );
  }

  Widget _buildCardContent(
      String title, String description, IconData iconData, ThemeData theme, Color splashColor) {
    return InkWell(
      splashColor: splashColor,
      highlightColor: splashColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(15.0),
      onTap: () { /* GestureDetector에서 처리하므로 여기서는 비워두거나 추가 액션 */ },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(iconData, size: 40.0, color: theme.primaryColor), // Color(0xFF7D9D81)
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.green.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16.0, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}