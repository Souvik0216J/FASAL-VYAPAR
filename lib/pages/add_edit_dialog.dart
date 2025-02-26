// // widgets/add_edit_dialog.dart
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../models/grocery_item.dart';

// class AddEditDialog extends StatefulWidget {
//   final GroceryItem? item;
//   final Function(GroceryItem) onSave;

//   const AddEditDialog({
//     Key? key,
//     this.item,
//     required this.onSave,
//   }) : super(key: key);

//   @override
//   State<AddEditDialog> createState() => _AddEditDialogState();
// }

// class _AddEditDialogState extends State<AddEditDialog> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _quantityController = TextEditingController();
//   final _priceController = TextEditingController();
//   final _categoryController = TextEditingController();
//   final _locationController = TextEditingController();
//   final _notesController = TextEditingController();

//   DateTime? _purchaseDate;
//   DateTime? _expiryDate;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.item != null) {
//       _nameController.text = widget.item!.name;
//       _quantityController.text = widget.item!.quantity.toString();
      
//       _expiryDate = widget.item!.expiryDate;
//     }
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _quantityController.dispose();
//     _priceController.dispose();
//     _categoryController.dispose();
//     _locationController.dispose();
//     _notesController.dispose();
//     super.dispose();
//   }

//   Future<void> _selectDate(BuildContext context, bool isExpiryDate) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: isExpiryDate
//           ? _expiryDate ?? DateTime.now().add(const Duration(days: 7))
//           : _purchaseDate ?? DateTime.now(),
//       firstDate: isExpiryDate
//           ? DateTime.now()
//           : DateTime(DateTime.now().year - 1),
//       lastDate: isExpiryDate
//           ? DateTime(DateTime.now().year + 5)
//           : DateTime.now(),
//     );

//     if (picked != null) {
//       setState(() {
//         if (isExpiryDate) {
//           _expiryDate = picked;
//         } else {
//           _purchaseDate = picked;
//         }
//       });
//     }
//   }

//   void _handleSubmit() {
//     if (_formKey.currentState!.validate()) {
//       final item = GroceryItem(
//         id: widget.item?.id ?? '',
//         name: _nameController.text,
//         quantity: int.parse(_quantityController.text),
       
//         expiryDate: _expiryDate ?? DateTime.now(),
  
//         isSold: widget.item?.isSold ?? false, ripeness: '',

//       );

//       widget.onSave(item);
//       Navigator.pop(context);
//     }
//   }

//   String _formatDate(DateTime? date) {
//     if (date == null) return 'Select date';
//     return DateFormat('MMM dd, yyyy').format(date);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isNewItem = widget.item == null;
    
//     return AlertDialog(
//       title: Text(isNewItem ? 'Add New Item' : 'Edit Item'),
//       content: SingleChildScrollView(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Item Name',
//                   hintText: 'Enter item name',
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a name';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: _quantityController,
//                       decoration: const InputDecoration(
//                         labelText: 'Quantity',
//                         hintText: 'Enter quantity',
//                       ),
//                       keyboardType: TextInputType.number,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Required';
//                         }
//                         if (int.tryParse(value) == null) {
//                           return 'Invalid number';
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: TextFormField(
//                       controller: _priceController,
//                       decoration: const InputDecoration(
//                         labelText: 'Price',
//                         hintText: 'Enter price',
//                         prefixText: '\$',
//                       ),
//                       keyboardType: TextInputType.number,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Required';
//                         }
//                         if (double.tryParse(value) == null) {
//                           return 'Invalid price';
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _categoryController,
//                 decoration: const InputDecoration(
//                   labelText: 'Category',
//                   hintText: 'Enter category',
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _locationController,
//                 decoration: const InputDecoration(
//                   labelText: 'Storage Location',
//                   hintText: 'Where is it stored?',
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: InkWell(
//                       onTap: () => _selectDate(context, false),
//                       child: InputDecorator(
//                         decoration: const InputDecoration(
//                           labelText: 'Purchase Date',
//                           border: OutlineInputBorder(),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(_formatDate(_purchaseDate)),
//                             const Icon(Icons.calendar_today),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: InkWell(
//                       onTap: () => _selectDate(context, true),
//                       child: InputDecorator(
//                         decoration: const InputDecoration(
//                           labelText: 'Expiry Date (Optional)',
//                           border: OutlineInputBorder(),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(_expiryDate == null
//                                 ? 'Select date'
//                                 : _formatDate(_expiryDate)),
//                             const Icon(Icons.calendar_today),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _notesController,
//                 decoration: const InputDecoration(
//                   labelText: 'Notes (Optional)',
//                   hintText: 'Enter any additional notes',
//                 ),
//                 maxLines: 3,
//               ),
//             ],
//           ),
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: _handleSubmit,
//           child: Text(isNewItem ? 'Add' : 'Save'),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/grocery_item.dart';

class AddEditDialog extends StatefulWidget {
  final GroceryItem? item;
  final Function(GroceryItem) onSave;

  const AddEditDialog({
    Key? key,
    this.item,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddEditDialog> createState() => _AddEditDialogState();
}

class _AddEditDialogState extends State<AddEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  DateTime? _expiryDate;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _quantityController.text = widget.item!.quantity.toString();
      _expiryDate = widget.item!.expiryDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (picked != null) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final item = GroceryItem(
        id: widget.item?.id ?? '',
        name: _nameController.text,
        quantity: int.parse(_quantityController.text),
        expiryDate: _expiryDate ?? DateTime.now(),
        isSold: widget.item?.isSold ?? false,
        ripeness: '',
      );

      widget.onSave(item);
      Navigator.pop(context);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isNewItem = widget.item == null;
    
    return AlertDialog(
      title: Text(isNewItem ? 'Add New Item' : 'Edit Item'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Item Name',
                hintText: 'Enter item name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                hintText: 'Enter quantity',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                if (int.tryParse(value) == null) {
                  return 'Invalid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Expiry Date',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDate(_expiryDate)),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          child: Text(isNewItem ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}