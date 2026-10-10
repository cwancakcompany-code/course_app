import '/backend/services/profile_service.dart';
import '/backend/ui/app_notify.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/pages/components/main_appbar/main_appbar_widget.dart';
import '/actions/actions.dart' as action_blocks;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'edit_profile_page_model.dart';
export 'edit_profile_page_model.dart';

class EditProfilePageWidget extends StatefulWidget {
  const EditProfilePageWidget({super.key});

  static String routeName = 'EditProfilePage';
  static String routePath = '/editProfilePage';

  @override
  State<EditProfilePageWidget> createState() => _EditProfilePageWidgetState();
}

class _EditProfilePageWidgetState extends State<EditProfilePageWidget> {
  late EditProfilePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditProfilePageModel());

    _model.textController1 ??=
        TextEditingController(text: FFAppState().userDetail.firstName);
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??=
        TextEditingController(text: FFAppState().userDetail.lastName);
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textController3 ??=
        TextEditingController(text: FFAppState().userDetail.email);
    _model.textFieldFocusNode3 ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrateFromServer());
  }

  Future<void> _hydrateFromServer() async {
    if (!FFAppState().isLogin) return;
    try {
      final profile = await _profileService.loadCurrentProfile();
      if (profile == null || !mounted) return;
      final email = FFAppState().userDetail.email;
      _profileService.syncAppState(profile, email);
      _model.textController1?.text = profile.firstName;
      _model.textController2?.text = profile.lastName;
      safeSetState(() {});
    } catch (e) {
      debugPrint('edit profile hydrate failed: $e');
    }
  }

  Widget _avatarPreview() {
    final pending = _model.uploadedLocalFile_uploadDataDr6;
    if (pending.bytes != null && pending.bytes!.isNotEmpty) {
      return Image.memory(
        pending.bytes!,
        width: 80.0,
        height: 80.0,
        fit: BoxFit.cover,
      );
    }
    final url = FFAppState().profileAvatarUrl;
    if (url.isNotEmpty) {
      return CachedNetworkImage(
        fadeInDuration: Duration(milliseconds: 200),
        fadeOutDuration: Duration(milliseconds: 200),
        imageUrl: url,
        width: 80.0,
        height: 80.0,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => Image.asset(
          'assets/images/Mentors2.png',
          fit: BoxFit.cover,
        ),
      );
    }
    return Image.asset(
      'assets/images/Mentors2.png',
      fit: BoxFit.cover,
    );
  }

  Future<void> _pickAvatar() async {
    final selectedMedia = await selectMediaWithSourceBottomSheet(
      context: context,
      maxWidth: 1024.0,
      maxHeight: 1024.0,
      imageQuality: 90,
      allowPhoto: true,
      textColor: FlutterFlowTheme.of(context).primaryText,
    );
    if (selectedMedia == null) return;
    if (!selectedMedia.every((m) => validateFileFormat(m.storagePath, context))) {
      return;
    }

    safeSetState(() => _model.isDataUploading_uploadDataDr6 = true);
    try {
      final file = selectedMedia.first;
      final bytes = file.bytes;
      if (bytes.isEmpty) {
        if (mounted) AppNotify.error(context, 'Could not read image');
        return;
      }
      // Soft client guard — hard compress happens in AvatarStorageService.
      if (bytes.lengthInBytes > 10 * 1024 * 1024) {
        if (mounted) {
          AppNotify.error(context, 'Image is too large (max 10 MB)');
        }
        return;
      }
      safeSetState(() {
        _model.uploadedLocalFile_uploadDataDr6 = FFUploadedFile(
          name: file.storagePath.split('/').last,
          bytes: bytes,
          height: file.dimensions?.height,
          width: file.dimensions?.width,
          blurHash: file.blurHash,
          originalFilename: file.originalFilename,
        );
      });
    } finally {
      if (mounted) {
        safeSetState(() => _model.isDataUploading_uploadDataDr6 = false);
      }
    }
  }

  Future<void> _save() async {
    if (!FFAppState().connected) {
      await action_blocks.internetSnackbar(context);
      return;
    }
    if (_model.formKey.currentState == null ||
        !_model.formKey.currentState!.validate()) {
      return;
    }
    if (_model.isSaving) return;

    safeSetState(() => _model.isSaving = true);
    try {
      final dial = FFAppState().countryCodeEdit.isNotEmpty
          ? FFAppState().countryCodeEdit
          : FFAppState().countryCode;
      final pending = _model.uploadedLocalFile_uploadDataDr6;
      await _profileService.updateProfile(
        firstName: _model.textController1.text,
        lastName: _model.textController2.text,
        phoneCountryCode: dial,
        phoneNumber: FFAppState().phone,
        avatarBytes:
            (pending.bytes != null && pending.bytes!.isNotEmpty)
                ? pending.bytes
                : null,
        avatarFileName: pending.originalFilename.isNotEmpty
            ? pending.originalFilename
            : pending.name,
        avatarMimeType: null,
      );
      if (!mounted) return;
      AppNotify.success(context, 'Profile updated');
      context.safePop();
    } on ProfileUpdateException catch (e) {
      if (mounted) AppNotify.error(context, e.message);
    } catch (_) {
      if (mounted) AppNotify.error(context, 'Could not update profile');
    } finally {
      if (mounted) safeSetState(() => _model.isSaving = false);
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              wrapWithModel(
                model: _model.mainAppbarModel,
                updateCallback: () => safeSetState(() {}),
                child: MainAppbarWidget(
                  title: 'Edit Profile',
                  isBack: true,
                  isEdit: false,
                  backAction: () async {
                    context.safePop();
                  },
                  editAction: () async {},
                ),
              ),
              Expanded(
                child: Form(
                  key: _model.formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(0, 48.0, 0, 16.0),
                    scrollDirection: Axis.vertical,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            20.0, 0.0, 20.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: AlignmentDirectional(1.0, 1.0),
                              children: [
                                Container(
                                  width: 80.0,
                                  height: 80.0,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: _model.isDataUploading_uploadDataDr6
                                      ? Center(
                                          child: SizedBox(
                                            width: 28,
                                            height: 28,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        )
                                      : _avatarPreview(),
                                ),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: _model.isSaving ? null : _pickAvatar,
                                  child: Container(
                                    width: 24.0,
                                    height: 24.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 16.0,
                                          color: FlutterFlowTheme.of(context)
                                              .shadowColor,
                                          offset: Offset(0.0, 4.0),
                                        )
                                      ],
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(0.0),
                                      child: SvgPicture.asset(
                                        'assets/images/Group_1171277900.svg',
                                        width: 20.0,
                                        height: 20.0,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            20.0, 50.0, 20.0, 0.0),
                        child: Container(
                          width: double.infinity,
                          child: TextFormField(
                            controller: _model.textController1,
                            focusNode: _model.textFieldFocusNode1,
                            autofocus: false,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            obscureText: false,
                            decoration: InputDecoration(
                              isDense: false,
                              labelText: 'First name',
                              labelStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: 'SF Pro Display',
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    fontSize: 13.0,
                                    letterSpacing: 0.0,
                                    lineHeight: 1.0,
                                  ),
                              hintText: 'First name',
                              hintStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: 'SF Pro Display',
                                    fontSize: 17.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                    lineHeight: 1.0,
                                  ),
                              errorStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'SF Pro Display',
                                    color: FlutterFlowTheme.of(context).error,
                                    fontSize: 15.0,
                                    letterSpacing: 0.0,
                                    lineHeight: 1.0,
                                  ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).black20,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).error,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).error,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              contentPadding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 16.5, 16.0, 16.5),
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'SF Pro Display',
                                  fontSize: 17.0,
                                  letterSpacing: 0.0,
                                  lineHeight: 1.0,
                                ),
                            cursorColor:
                                FlutterFlowTheme.of(context).primaryText,
                            validator: _model.textController1Validator
                                .asValidator(context),
                            inputFormatters: [
                              if (!isAndroid && !isiOS)
                                TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
                                  return TextEditingValue(
                                    selection: newValue.selection,
                                    text: newValue.text.toCapitalization(
                                        TextCapitalization.sentences),
                                  );
                                }),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            20.0, 26.0, 20.0, 26.0),
                        child: Container(
                          width: double.infinity,
                          child: TextFormField(
                            controller: _model.textController2,
                            focusNode: _model.textFieldFocusNode2,
                            autofocus: false,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            obscureText: false,
                            decoration: InputDecoration(
                              isDense: false,
                              labelText: 'Last name',
                              labelStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: 'SF Pro Display',
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    fontSize: 13.0,
                                    letterSpacing: 0.0,
                                    lineHeight: 1.0,
                                  ),
                              hintText: 'Last name',
                              hintStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: 'SF Pro Display',
                                    fontSize: 17.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                    lineHeight: 1.0,
                                  ),
                              errorStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'SF Pro Display',
                                    color: FlutterFlowTheme.of(context).error,
                                    fontSize: 15.0,
                                    letterSpacing: 0.0,
                                    lineHeight: 1.0,
                                  ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).black20,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).error,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).error,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              contentPadding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 16.5, 16.0, 16.5),
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'SF Pro Display',
                                  fontSize: 17.0,
                                  letterSpacing: 0.0,
                                  lineHeight: 1.0,
                                ),
                            cursorColor:
                                FlutterFlowTheme.of(context).primaryText,
                            validator: _model.textController2Validator
                                .asValidator(context),
                            inputFormatters: [
                              if (!isAndroid && !isiOS)
                                TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
                                  return TextEditingValue(
                                    selection: newValue.selection,
                                    text: newValue.text.toCapitalization(
                                        TextCapitalization.sentences),
                                  );
                                }),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            20.0, 0.0, 20.0, 0.0),
                        child: Container(
                          width: double.infinity,
                          child: TextFormField(
                            controller: _model.textController3,
                            focusNode: _model.textFieldFocusNode3,
                            autofocus: false,
                            textInputAction: TextInputAction.next,
                            readOnly: true,
                            obscureText: false,
                            decoration: InputDecoration(
                              isDense: false,
                              labelText: 'Email address',
                              labelStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: 'SF Pro Display',
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    fontSize: 13.0,
                                    letterSpacing: 0.0,
                                    lineHeight: 1.0,
                                  ),
                              hintText: 'Email address',
                              hintStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: 'SF Pro Display',
                                    fontSize: 17.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                    lineHeight: 1.0,
                                  ),
                              errorStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'SF Pro Display',
                                    color: FlutterFlowTheme.of(context).error,
                                    fontSize: 15.0,
                                    letterSpacing: 0.0,
                                    lineHeight: 1.0,
                                  ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              filled: true,
                              fillColor: FlutterFlowTheme.of(context).lightGray,
                              contentPadding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 16.5, 16.0, 16.5),
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'SF Pro Display',
                                  fontSize: 17.0,
                                  letterSpacing: 0.0,
                                  lineHeight: 1.0,
                                ),
                            keyboardType: TextInputType.emailAddress,
                            cursorColor:
                                FlutterFlowTheme.of(context).primaryText,
                            validator: _model.textController3Validator
                                .asValidator(context),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            20.0, 26.0, 20.0, 0.0),
                        child: custom_widgets.CustomLabelCountryCodeWidget(
                          width: double.infinity,
                          height: 50.0,
                          initialValue: FFAppState().phone.isNotEmpty
                              ? FFAppState().phone
                              : FFAppState().userDetail.phoneNumber,
                          initialCountryCodeLocal:
                              FFAppState().countryName.isNotEmpty
                                  ? FFAppState().countryName
                                  : 'IQ',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.0, 12.0, 20.0, 24.0),
                child: FFButtonWidget(
                  onPressed: _model.isSaving ? null : _save,
                  text: _model.isSaving ? 'Updating...' : 'Update Profile',
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 54.0,
                    padding:
                        EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                    iconPadding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'SF Pro Display',
                          color: Colors.white,
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
                          lineHeight: 1.0,
                        ),
                    elevation: 0.0,
                    borderRadius: BorderRadius.circular(16.0),
                    disabledColor: FlutterFlowTheme.of(context)
                        .primary
                        .withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
