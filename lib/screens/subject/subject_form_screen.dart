import 'package:flutter/material.dart';
import 'package:mi_estudio/utils/custom_toast.dart';
import 'package:mi_estudio/utils/listas/colors.dart';
import 'package:mi_estudio/utils/listas/iconos.dart';
import 'package:mi_estudio/utils/provider/subject_from_provider.dart';
import 'package:provider/provider.dart';

class SubjectFormScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  
  const SubjectFormScreen({super.key, this.initialData});

  @override
  State<SubjectFormScreen> createState() => _SubjectFormScreenState();
}

class _SubjectFormScreenState extends State<SubjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final SubjectFromProvider _provider = Provider.of<SubjectFromProvider>(context);


  @override
  Widget build(BuildContext context) {
    final separated = const SizedBox(height: 30);
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 500; 

    return Scaffold(
      appBar: AppBar(
        title: Text('Nueva materia', style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
            _provider.clear();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveSubject,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _previewCard(theme),
              separated,
              TextFormField(
                controller: _provider.conName,
                decoration: InputDecoration(
                  labelText: 'Nombre de la materia',
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Por favor ingresa un nombre' : null,
                onChanged: (value) => _provider.setNombre(value),
              ),
              separated,
              Text('Color de la materia', style: theme.textTheme.bodyLarge),
              const SizedBox(height: 10),
              SizedBox(
                height: 75, 
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: pastelColors.length,
                  separatorBuilder: (context, index) => SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return InkWell(
                      splashColor: Colors.transparent,
                      onTap: () => _provider.setColor(pastelColors[index]),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: pastelColors[index],
                          shape: BoxShape.circle,
                          border: _provider.getColor == pastelColors[index]
                              ? Border.all(color: theme.brightness == Brightness.dark ? Colors.white :Colors.black, width: 3)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: theme.brightness == Brightness.dark ? Colors.white24 : Colors.black12,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: _provider.getColor  == pastelColors[index]
                            ? Icon(Icons.check, color: theme.brightness == Brightness.dark ? Colors.white :Colors.black, size: 20)
                            : null,
                      ),
                    );
                  },
                ),
              ),
              separated,
              Text('Ícono de la materia', style: theme.textTheme.bodyLarge),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide ? 12 : 6,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: subjectIcons.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _provider.setIcono(subjectIcons[index]),
                    child: Container(
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: _provider.getIcono == subjectIcons[index] ? _provider.getColor.withOpacity(0.3) : null,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        subjectIcons[index],
                        color: _provider.getIcono == subjectIcons[index] ? darken(_provider.getColor) : theme.brightness == Brightness.dark ? Colors.white : Colors.grey[600],
                        size: 30,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Vista previa de cómo quedará la materia
  Widget _previewCard(ThemeData theme) {
    return Center(
      child: Container(
        width: 200,
        height: 150,
        padding: const EdgeInsets.only(left: 15, top: 10, bottom: 15, right: 15),
        decoration: BoxDecoration(
          color: _provider.getColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.brightness == Brightness.dark ? Colors.white24 : Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Icon(_provider.getIcono, size: 60, color: darken(_provider.getColor)),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                softWrap: true,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                _provider.isValid() ? _provider.conName.text : 'Materia',
                style: theme.textTheme.labelSmall?.copyWith(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Función para oscurecer colores (para texto/íconos)
  Color darken(Color color, [double amount = 0.3]) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  // Guardar la materia
  Future<void> _saveSubject() async {
    if (_formKey.currentState!.validate()) {    
      _provider.saveSubject();
      CustomToast.show(context, _provider.getDocId != null ? 'Materia actualizada' : 'Materia creada');
      Navigator.pop(context);
    }
  }
}