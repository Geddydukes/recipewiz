import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/shopping_list_service.dart';
import '../../models/shopping_list.dart';

class ShoppingListPage extends StatelessWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Lists'),
      ),
      body: StreamBuilder<List<ShoppingList>>(
        stream: context.read<ShoppingListService>().getShoppingLists(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }

          final lists = snapshot.data ?? [];
          if (lists.isEmpty) {
            return const Center(
              child: Text(
                'No shopping lists yet',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: lists.length,
            itemBuilder: (context, index) {
              final list = lists[index];
              return Dismissible(
                key: Key(list.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  context.read<ShoppingListService>().deleteShoppingList(list.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Shopping list deleted'),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ExpansionTile(
                    title: Text(
                      list.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${list.items.length} items',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: list.items.length,
                        itemBuilder: (context, itemIndex) {
                          final item = list.items[itemIndex];
                          return CheckboxListTile(
                            value: item.isChecked,
                            onChanged: (value) {
                              if (value != null) {
                                context
                                    .read<ShoppingListService>()
                                    .toggleItemCheck(list.id, itemIndex);
                              }
                            },
                            title: Text(
                              item.name,
                              style: TextStyle(
                                decoration: item.isChecked
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: item.isChecked
                                    ? Colors.grey[500]
                                    : Colors.black,
                              ),
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                context
                                    .read<ShoppingListService>()
                                    .clearCheckedItems(list.id);
                              },
                              icon: const Icon(Icons.clear_all),
                              label: const Text('Clear Checked'),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                context
                                    .read<ShoppingListService>()
                                    .checkAllItems(list.id);
                              },
                              icon: const Icon(Icons.done_all),
                              label: const Text('Check All'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
