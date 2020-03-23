import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/product.dart';
import 'package:shop/providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const String routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _productBeingEdited = Product(
      id: null,
      description: '',
      imageUrl: '',
      price: 0.0,
      title: '',
      isFavorite: false);

  var _isInit = false;

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        final product = Provider.of<ProductProvider>(context, listen: false)
            .findById(productId);
        _productBeingEdited = _productBeingEdited.copyWith(
          id: product.id,
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl,
          isFavorite: product.isFavorite,
        );
        _imageUrlController.text = _productBeingEdited.imageUrl;
      }
      _isInit = true;
    }
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _imageUrlFocusNode.addListener(onImageUrlFocusChanged);
    super.initState();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(onImageUrlFocusChanged);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void onImageUrlFocusChanged() {
    if (!_imageUrlFocusNode.hasFocus) {
      _formKey.currentState.validate();
      setState(() {});
    }
  }

  void _onSave() {
    bool isPassValidation = _formKey.currentState.validate();
    if (!isPassValidation) return;

    _formKey.currentState.save();
    print(_productBeingEdited);
    Provider.of<ProductProvider>(context, listen: false)
        .upsertProduct(_productBeingEdited);
    Navigator.of(context).pop();
  }

  bool isValidUrl(String url) {
    var urlPattern =
        r"(https?|ftp)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
    var result = new RegExp(urlPattern, caseSensitive: false).firstMatch(url);
    return result != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Edit Product'),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.save), onPressed: _onSave),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    initialValue: _productBeingEdited.title,
                    decoration: InputDecoration(
                      labelText: 'Title',
                    ),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_priceFocusNode);
                    },
                    onSaved: (value) => _productBeingEdited =
                        _productBeingEdited.copyWith(title: value),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Title required!';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: _productBeingEdited.price.toString(),
                    decoration: InputDecoration(
                      labelText: 'Price',
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    focusNode: _priceFocusNode,
                    onSaved: (value) => _productBeingEdited =
                        _productBeingEdited.copyWith(
                            price: double.parse(value)),
                    onFieldSubmitted: (_) {
                      FocusScope.of(context)
                          .requestFocus(_descriptionFocusNode);
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Price required!';
                      }

                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number!';
                      }

                      if (double.tryParse(value) < 0) {
                        return 'Please enter a number greater than zero!';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: _productBeingEdited.description,
                    decoration: InputDecoration(
                      labelText: 'Description',
                    ),
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    focusNode: _descriptionFocusNode,
                    onSaved: (value) => _productBeingEdited =
                        _productBeingEdited.copyWith(description: value),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Description required!';
                      }

                      if (value.length < 10) {
                        return 'Description should be more than 10 characters!';
                      }
                      return null;
                    },
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        width: 100,
                        height: 100,
                        margin: EdgeInsets.only(
                          top: 8,
                          right: 10,
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(
                          width: 1,
                          color: Colors.grey,
                        )),
                        child: _imageUrlController.text.isEmpty
                            ? Text('Enter a URL')
                            : FittedBox(
                                child: Image.network(_imageUrlController.text),
                                fit: BoxFit.cover,
                              ),
                      ),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Image URL',
                          ),
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) {
                            _onSave();
                          },
                          onSaved: (value) => _productBeingEdited =
                              _productBeingEdited.copyWith(imageUrl: value),
                          controller: _imageUrlController,
                          focusNode: _imageUrlFocusNode,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Image URL required!';
                            }

                            if (!isValidUrl(value)) {
                              return 'Please make sure that the url is in a valid format';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
