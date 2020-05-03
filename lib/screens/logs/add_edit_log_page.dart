import 'package:currency_pickers/utils/utils.dart';
import 'package:expenses/models/log/log.dart';
import 'package:expenses/screens/common_widgets/my_currency_picker.dart';
import 'package:flutter/material.dart';

class AddEditLogPage extends StatefulWidget {
  final Log log;

  const AddEditLogPage({Key key, this.log}) : super(key: key);

  @override
  _AddEditLogPageState createState() => _AddEditLogPageState();
}

class _AddEditLogPageState extends State<AddEditLogPage> {
  Log _log;
  String _currency;

  void _submit() {
    //TODO create submit method
  }

  @override
  Widget build(BuildContext context) {
    Log _log = widget.log;

    //TODO upgrade to blocBuilder to handle events

    return Scaffold(
      appBar: AppBar(
        title: Text('Entry'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.check,
              color: Colors.white,
            ),
            onPressed:
                () {}, // ? null : _submit, TODO need to use state to take care of this with SavingLogState
          )
        ],
      ),
      body: _buildContents(context),
    );
  }

  Widget _buildContents(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                _buildForm(),
                SizedBox(height: 16.0),
                _currency == null
                    ? MyCurrencyPicker(
                        currency: _currency,
                        returnCurrency: (currency) => _currency = currency)
                    : Text(
                        'Currency: ${CurrencyPickerUtils.getCountryByIsoCode(_currency).currencyCode}'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Log Title'),
      //TODO get initial value from state
      validator: (value) =>
          value.isNotEmpty ? null : 'Expense log name can\'t be empty',
      //TODO on saved
    );
  }
}
