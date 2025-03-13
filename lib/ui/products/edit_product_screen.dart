import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../shared/dialog_utils.dart';
import 'products_manager.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit_product';

  EditProductScreen(
    Product? product, {
    super.key,
  }) {
    if (product == null) {
      this.product = Product(
        id: null,
        title: '',
        price: 0,
        description: '',
        imageUrl: '',
      );
    } else {
      this.product = product;
    }
  }
  late final Product product;
  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  // final _imageUrlController = TextEditingController();
  // final _imageUrlFocusNode = FocusNode();
  final _editForm = GlobalKey<FormState>();
  late Product _editedProduct;

  // bool _isValidImageUrl(String value) {
  //   return (value.startsWith('http') || value.startsWith('https')) &&
  //       (value.endsWith('.png') ||
  //           value.endsWith('jpg') ||
  //           value.endsWith('jpeg'));
  // }

  @override
  void initState() {
    // _imageUrlFocusNode.addListener(() {
    //   if (!_imageUrlFocusNode.hasFocus) {
    //     if (!_isValidImageUrl(_imageUrlController.text)) {
    //       return;
    //     }
    //     //ảnh hợp lệ -> vẽ lại màn hình để hiện preview
    //     setState(() {});
    //   }
    // });
    _editedProduct = widget.product;
    // _imageUrlController.text = _editedProduct.imageUrl;
    super.initState();
  }

  // @override
  // void dispose() {
  //   _imageUrlController.dispose();
  //   _imageUrlFocusNode.dispose();
  //   super.dispose();
  // }

  Future<void> _saveForm() async {
    // final isValid = _editForm.currentState!.validate();
    final isValid =
        _editForm.currentState!.validate() && _editedProduct.hasFeaturedImage();
    if (!isValid) {
      return;
    }
    _editForm.currentState!.save();

    try {
      final productsManager = context.read<ProductsManager>();
      if (_editedProduct.id != null) {
        await productsManager.updateProduct(_editedProduct);
      } else {
        await productsManager.addProduct(_editedProduct);
      }
    } catch (err) {
      await showErrorDialog(context, 'Something went wrong!');
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  TextFormField _buildTitleField() {
    return TextFormField(
      initialValue: _editedProduct.title,
      decoration: const InputDecoration(labelText: 'Title'),
      textInputAction: TextInputAction.next,
      autofocus: true,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please provide a value.';
        }
        return null;
      },
      onSaved: (value) {
        _editedProduct = _editedProduct.copyWith(title: value);
      },
    );
  }

  TextFormField _buildPriceField() {
    return TextFormField(
      initialValue: _editedProduct.price.toString(),
      decoration: const InputDecoration(labelText: 'Price'),
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter a valid number.';
        }
        if (double.parse(value) <= 0) {
          return "Please enter a number greater than zero.";
        }
        return null;
      },
      onSaved: (value) {
        _editedProduct = _editedProduct.copyWith(price: double.parse(value!));
      },
    );
  }

  TextFormField _buildDescriptionField() {
    return TextFormField(
      initialValue: _editedProduct.description,
      decoration: const InputDecoration(labelText: 'Description'),
      maxLines: 3,
      keyboardType: TextInputType.multiline,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter a description.';
        }
        if (value.length < 10) {
          return 'Should be at least 10 characters long.';
        }
        return null;
      },
      onSaved: (value) {
        _editedProduct = _editedProduct.copyWith(description: value);
      },
    );
  }

  Widget _buildProductPreview() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(top: 8, right: 10),
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
          ),
          // child: _imageUrlController.text.isEmpty
          //   ? const Text('Enter a URL') //nếu chưa có đường dẫn thì thông báo cho người dùng nhập vào
          child: !_editedProduct.hasFeaturedImage()
              ? const Center(child: Text('No Image'))
              : FittedBox(
                  // child: Image.network(
                  // _imageUrlController.text,
                  child: _editedProduct.featuredImage == null
                      ? Image.network(
                          _editedProduct.imageUrl,
                          fit: BoxFit.cover,
                        )
                      // fit: BoxFit.cover,
                      : Image.file(
                          _editedProduct.featuredImage!,
                          fit: BoxFit.cover,
                        ),
                ),
        ),
        Expanded(
          // child: _buildImageURLField(),
          child: SizedBox(height: 100, child: _buildImagePickerButton()),
        ),
      ],
    );
  }

  // TextFormField _buildImageURLField() {
  //   return TextFormField(
  //     decoration: const InputDecoration(labelText: 'Image URL'),
  //     keyboardType: TextInputType.url,
  //     textInputAction: TextInputAction.done,
  //     controller: _imageUrlController,
  //     focusNode: _imageUrlFocusNode,
  //     onFieldSubmitted: (value) => _saveForm(),
  //     validator: (value) {
  //       if (value!.isEmpty) {
  //         return 'Please enter an image URL.';
  //       }
  //       if (!_isValidImageUrl(value)) {
  //         return 'Please enter a valid image URL.';
  //       }
  //       return null;
  //     },
  //     onSaved: (value) {
  //       _editedProduct = _editedProduct.copyWith(imageUrl: value);
  //     },
  //   );
  // }

  TextButton _buildImagePickerButton() {
    return TextButton.icon(
      icon: const Icon(Icons.image),
      label: const Text('Pick Image'),
      onPressed: () async {
        final imagePicker = ImagePicker();
        try {
          final imageFile = 
            await imagePicker.pickImage(source: ImageSource.gallery);
          if (imageFile == null) {
            return;
          }
          _editedProduct = _editedProduct.copyWith(
            featuredImage: File(imageFile.path),
          );
          setState(() {});
        } catch (e) {
          if (mounted) {
            showErrorDialog(context, 'Something went wrong!');
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            onPressed: _saveForm,
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
              key: _editForm,
              child: ListView(
                children: <Widget>[
                  _buildTitleField(),
                  _buildPriceField(),
                  _buildDescriptionField(),
                  _buildProductPreview(),
                ],
              ))),
    );
  }
}
