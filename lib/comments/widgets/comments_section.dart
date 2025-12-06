import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srumec_app/comments/models/comment.dart';
import 'package:srumec_app/comments/providers/comments_provider.dart';

class CommentsSection extends StatefulWidget {
  final String eventId;

  const CommentsSection({super.key, required this.eventId});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // Načteme komentáře hned po vložení widgetu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommentsProvider>().loadComments(widget.eventId);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);

    // Zavoláme provider
    final success = await context.read<CommentsProvider>().sendComment(
      widget.eventId,
      text,
    );

    if (mounted) {
      setState(() => _isSending = false);
      if (success) {
        _controller.clear();
        FocusScope.of(context).unfocus(); // Skryj klávesnici
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chyba při odesílání komentáře')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sledujeme změny v provideru
    final provider = context.watch<CommentsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Komentáře',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // 1. SEZNAM KOMENTÁŘŮ
        if (provider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (provider.comments.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Zatím žádné komentáře. Buď první!',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true, // Důležité, protože jsme uvnitř jiného ListView
            physics:
                const NeverScrollableScrollPhysics(), // Scrolluje celý detail, ne jen komentáře
            itemCount: provider.comments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildCommentItem(provider.comments[index]);
            },
          ),

        const SizedBox(height: 16),

        // 2. VSTUPNÍ POLE
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Napsat komentář...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _isSending ? null : _submitComment,
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                comment.userId,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                "${comment.createdAt.day}.${comment.createdAt.month}. ${comment.createdAt.hour}:${comment.createdAt.minute}",
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(comment.content),
        ],
      ),
    );
  }
}
