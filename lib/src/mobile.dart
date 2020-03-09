import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'impl.dart';

class EasyWebView extends StatefulWidget implements EasyWebViewImpl {
  const EasyWebView({
    Key key,
    @required this.src,
    this.height,
    this.width,
    this.webAllowFullScreen = true,
    this.isHtml = false,
    this.isMarkdown = false,
    this.convertToWidets = false,
    this.headers = const {},
    this.widgetsTextSelectable = false,
  })  : assert((isHtml && isMarkdown) == false),
        super(key: key);

  @override
  _EasyWebViewState createState() => _EasyWebViewState();

  @override
  final num height;

  @override
  final String src;

  @override
  final num width;

  @override
  final bool webAllowFullScreen;

  @override
  final bool isMarkdown;

  @override
  final bool isHtml;

  @override
  final bool convertToWidets;

  @override
  final Map<String, String> headers;

  @override
  final bool widgetsTextSelectable;
}

class _EasyWebViewState extends State<EasyWebView> {
  WebViewController _controller;

  @override
  void didUpdateWidget(EasyWebView oldWidget) {
    if (oldWidget.src != widget.src) {
      _controller.loadUrl(_updateUrl(widget.src), headers: widget.headers);
    }
    if (oldWidget.height != widget.height) {
      if (mounted) setState(() {});
    }
    if (oldWidget.width != widget.width) {
      if (mounted) setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  String _updateUrl(String url) {
    String _src = url;
    if (widget.isMarkdown) {
      _src = "data:text/html;charset=utf-8," +
          Uri.encodeComponent(EasyWebViewImpl.md2Html(url));
    }
    if (widget.isHtml) {
      _src = "data:text/html;charset=utf-8," +
          Uri.encodeComponent(EasyWebViewImpl.wrapHtml(url));
    }
    return _src;
  }

  @override
  Widget build(BuildContext context) {
    return OptionalSizedChild(
      width: widget?.width,
      height: widget?.height,
      builder: (w, h) {
        String src = widget.src;
        if (widget.convertToWidets) {
          if (EasyWebViewImpl.isUrl(src)) {
            return RemoteMarkdown(
              src: src,
              headers: widget.headers,
              isSelectable: widget.widgetsTextSelectable,
            );
          }
          String _markdown = '';
          if (widget.isMarkdown) {
            _markdown = src;
          }
          if (widget.isHtml) {
            src = EasyWebViewImpl.wrapHtml(src);
            _markdown = EasyWebViewImpl.html2Md(src);
          }
          return LocalMarkdown(
            data: _markdown,
            isSelectable: widget.widgetsTextSelectable,
          );
        }
        return WebView(
          key: widget?.key,
          initialUrl: _updateUrl(src),
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (val) {
            _controller = val;
          },
        );
      },
    );
  }
}
