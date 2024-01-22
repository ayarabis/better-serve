library better_serve_lib;

import 'package:better_serve/core/extenstions.dart';
import 'package:flutter/material.dart';

class DialogPane extends StatefulWidget {
  final Widget? child;
  final Widget? header;
  final TabBar? tabs;
  final Widget? footer;
  final Widget Function(BuildContext context, Function() toggleLoadding)?
      headerBuilder;
  final Widget Function(BuildContext context, Function() toggleLoadding)?
      footerBuilder;
  final Widget Function(BuildContext context, Function() toggleLoadding)?
      builder;
  final String tag;
  final double width;
  final double minHeight;
  final double? maxHeight;
  final bool scrollable;
  const DialogPane({
    Key? key,
    this.builder,
    this.child,
    this.header,
    this.footer,
    this.tabs,
    this.headerBuilder,
    this.footerBuilder,
    required this.tag,
    required this.width,
    this.minHeight = 0,
    this.maxHeight,
    this.scrollable = false,
  }) : super(key: key);

  @override
  State<DialogPane> createState() => _DialogPaneState();
}

class _DialogPaneState extends State<DialogPane> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    Size size = context.screenSize;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: widget.tag,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: widget.width > size.width
                      ? size.width * 0.8
                      : widget.width,
                  minHeight: widget.minHeight,
                  maxHeight: widget.maxHeight ??
                      size.height *
                          (context.viewInsets.bottom == 0 ? 0.8 : 0.9),
                ),
                child: Material(
                  borderRadius: BorderRadius.circular(10),
                  elevation: 5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        getContent(),
                        if (loading)
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              alignment: Alignment.center,
                              color: Colors.black.withAlpha(100),
                              child: const Card(
                                child: Padding(
                                  padding: EdgeInsets.all(15),
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  void setLoading() {
    setState(
      () {
        loading = !loading;
      },
    );
  }

  Widget getContent() {
    Widget body = widget.child ??
        widget.builder!(
          context,
          setLoading,
        );

    Widget divider = const Divider(
      height: 2,
    );
    final ScrollController controllerOne = ScrollController();
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.header != null) ...[
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: widget.header!,
          ),
          divider,
          if (widget.tabs != null) ...[widget.tabs!, divider]
        ] else if (widget.headerBuilder != null) ...[
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: widget.headerBuilder!(context, setLoading),
          ),
          divider
        ],
        if (widget.scrollable)
          Flexible(
            child: Scrollbar(
              trackVisibility: true,
              thumbVisibility: true,
              controller: controllerOne,
              child: SingleChildScrollView(
                controller: controllerOne,
                child: body,
              ),
            ),
          )
        else
          body,
        if (widget.footer != null) ...[
          const SizedBox(
            height: 5,
          ),
          divider,
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: widget.footer!,
          )
        ] else if (widget.footerBuilder != null) ...[
          const SizedBox(
            height: 5,
          ),
          divider,
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: widget.footerBuilder!(context, setLoading),
          )
        ]
      ],
    );
    if (widget.scrollable) {
      return content;
    }

    return SingleChildScrollView(child: content);
  }
}
