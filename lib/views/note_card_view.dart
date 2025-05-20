import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NoteCardView extends StatelessWidget {
  const NoteCardView({super.key, required this.subject, required this.note});

  final QueryDocumentSnapshot<Object?>? subject;
  final QueryDocumentSnapshot<Object?> note;

  Color darken(Color color, [double amount = .3]) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  @override
  Widget build(BuildContext context) {
    final noteData = note.data() as Map<String, dynamic>;
    final theme = Theme.of(context);
    final color = subject != null ? Color(subject!['color']) : null;
    final bool hasFiles = noteData['hasAttachments'] == true;
    final List<dynamic> fileUrls = hasFiles ? (noteData['fileUrls'] ?? []) as List<dynamic> : [];

    final separador8 = const SizedBox(height: 8);


    final imageUrls = fileUrls.where((url) =>
      url.toString().toLowerCase().endsWith('.jpg') ||
      url.toString().toLowerCase().endsWith('.jpeg') ||
      url.toString().toLowerCase().endsWith('.png') ||
      url.toString().toLowerCase().endsWith('.webp') 
    ).toList();

    final noImageFiles = fileUrls.where((url) =>
      !(url.toString().toLowerCase().endsWith('.jpg') ||
      url.toString().toLowerCase().endsWith('.jpeg') ||
      url.toString().toLowerCase().endsWith('.png') ||
      url.toString().toLowerCase().endsWith('.webp'))
    ).toList();


    Widget? imageWidget;
    if (imageUrls.isNotEmpty) {
      if (imageUrls.length == 1) {
        imageWidget = ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            imageUrl: imageUrls[0],
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.broken_image),
          )
        );
      } else if (imageUrls.length == 2) {
        imageWidget = Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: imageUrls[0],
                  height: 150,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: imageUrls[1],
                  height: 150,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                ),
              ),
            ),
          ],
        );
      } else {
        // 3 o más imágenes
        imageWidget = SizedBox(
          height: 150,
          child: Row(
            children: [
              // Primera imagen (izquierda)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: imageUrls[0],
                    height: 150,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Segunda y tercera imagen (derecha, arriba y abajo)
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: imageUrls[1],
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: ColorFiltered(
                              colorFilter: imageUrls.length > 3
                                  ? ColorFilter.mode(Colors.black38, BlendMode.darken)
                                  : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                              child: CachedNetworkImage(
                                imageUrl: imageUrls[2],
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                          if (imageUrls.length > 3)
                            Positioned.fill(
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text('+${imageUrls.length - 2}',
                                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: subject != null ? null : Border.all(color: Colors.grey, width: 2),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageWidget != null) ...[
            imageWidget,
            separador8,
          ],
          Text(note['title'], style: theme.textTheme.titleLarge!.copyWith(fontSize: 14)),
          if (noImageFiles.isNotEmpty) ...[
            separador8,
            Row(
              children: [
                Icon(Icons.insert_drive_file, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    noImageFiles.first.toString().split('/').last, // nombre del archivo
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (noImageFiles.length > 1) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('+${noImageFiles.length - 1}',style: theme.textTheme.labelSmall),
                  ),
                ]
              ],
            ),
          ],
          if ((imageWidget == null && noImageFiles.isEmpty) && (noteData['content'] != null && (noteData['content'] as String).trim().isNotEmpty)) ...[
            separador8,
            Text(
              noteData['content'],
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}