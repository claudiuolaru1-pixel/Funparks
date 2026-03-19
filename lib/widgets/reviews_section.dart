import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/reviews_service.dart';

class ReviewsSection extends StatefulWidget {
  final String parkId;
  final String itemId;

  const ReviewsSection({
    super.key,
    required this.parkId,
    required this.itemId,
  });

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  final _commentCtrl = TextEditingController();
  double _rating = 5.0;
  bool _submitting = false;
  bool _showForm = false;
  String? _error;

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final comment = _commentCtrl.text.trim();
    if (comment.isEmpty) {
      setState(() => _error = 'Please write a comment.');
      return;
    }
    setState(() { _submitting = true; _error = null; });
    try {
      await ReviewsService.postReview(
        parkId: widget.parkId,
        itemId: widget.itemId,
        rating: _rating,
        comment: comment,
      );
      _commentCtrl.clear();
      setState(() { _showForm = false; _submitting = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review posted!')));
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to post review. Try again.';
        _submitting = false;
      });
    }
  }

  Future<void> _delete() async {
    await ReviewsService.deleteReview(
      parkId: widget.parkId,
      itemId: widget.itemId,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review deleted.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Meta (average + count) ──
        StreamBuilder<ReviewMeta>(
          stream: ReviewsService.metaStream(widget.parkId, widget.itemId),
          builder: (_, snap) {
            final meta = snap.data ?? ReviewMeta(average: 0, count: 0);
            return Row(
              children: [
                Icon(Icons.star_rounded,
                    color: Colors.amber.shade600, size: 22),
                const SizedBox(width: 4),
                Text(
                  meta.count == 0
                      ? 'No reviews yet'
                      : '${meta.average.toStringAsFixed(1)}  ·  ${meta.count} review${meta.count == 1 ? '' : 's'}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),

        // ── Write review button or login prompt ──
        if (_user == null)
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/signin'),
            icon: const Icon(Icons.login),
            label: const Text('Log in to write a review'),
          )
        else if (!_showForm)
          FilledButton.icon(
            onPressed: () => setState(() => _showForm = true),
            icon: const Icon(Icons.rate_review),
            label: const Text('Write a review'),
          )
        else
          _buildForm(cs),

        const SizedBox(height: 20),

        // ── All comments ──
        StreamBuilder<List<ReviewComment>>(
          stream: ReviewsService.commentsStream(
              widget.parkId, widget.itemId),
          builder: (_, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final comments = snap.data ?? [];
            if (comments.isEmpty) {
              return Text('No reviews yet. Be the first!',
                  style: TextStyle(color: Colors.grey.shade600));
            }
            return Column(
              children: comments
                  .map((c) => _CommentCard(
                        comment: c,
                        isOwn: c.uid == _user?.uid,
                        onDelete: _delete,
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildForm(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your rating',
              style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          _StarRow(
              value: _rating,
              onChanged: (v) => setState(() => _rating = v)),
          const SizedBox(height: 14),
          const Text('Your comment',
              style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          TextField(
            controller: _commentCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Share your experience…',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!,
                style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton(
                onPressed: () =>
                    setState(() { _showForm = false; _error = null; }),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Post review'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _StarRow({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final starVal = i + 1.0;
        return GestureDetector(
          onTap: () => onChanged(starVal),
          child: Icon(
            value >= starVal ? Icons.star_rounded : Icons.star_outline_rounded,
            color: Colors.amber.shade600,
            size: 32,
          ),
        );
      }),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final ReviewComment comment;
  final bool isOwn;
  final VoidCallback onDelete;

  const _CommentCard({
    required this.comment,
    required this.isOwn,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOwn
            ? cs.primaryContainer.withOpacity(0.3)
            : cs.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isOwn
                ? cs.primary.withOpacity(0.3)
                : cs.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Stars
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < comment.rating.round()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: Colors.amber.shade600,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  comment.email,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isOwn)
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(Icons.delete_outline,
                      size: 18, color: Colors.red.shade400),
                ),
            ],
          ),
          if (comment.comment.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(comment.comment,
                style: const TextStyle(fontSize: 14, height: 1.4)),
          ],
          if (comment.date != null) ...[
            const SizedBox(height: 4),
            Text(
              _formatDate(comment.date!),
              style:
                  TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }
}