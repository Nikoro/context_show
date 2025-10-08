<p align="center">
  <a href="https://pub.dev/packages/context_show"><img src="https://raw.githubusercontent.com/nikoro/context_show/main/images/logo.webp" width="500"/></a>
</p>
<p align="center">
  <a href="https://pub.dev/packages/context_show">
    <img alt="Pub Package" src="https://tinyurl.com/ymd6xben">
  </a>
  <a href="https://github.com/Nikoro/context_show/actions">
    <img alt="Build Status" src="https://github.com/Nikoro/context_show/actions/workflows/build.yaml/badge.svg">
  </a>
  <a href="https://opensource.org/licenses/MIT">
    <img alt="MIT License" src="https://tinyurl.com/3uf9tzpy">
  </a>
</p>


A Flutter package that provides a simple and powerful way to show custom **overlays**, **toasts**, **banners**, **snackbars**, **dialogs** etc. using the `BuildContext`.

## Introduction

[`context_show`](https://pub.dev/packages/context_show) simplifies the process of displaying temporary widgets on the screen. It extends `BuildContext` with a `show()` method that allows you to render any widget as an overlay, with full control over alignment, duration, and animations.

Say goodbye to boilerplate code for managing `OverlayEntry` and `AnimationController`.

## Features

- 🪄 **Simple API**: Show your widget with a single line of code: `context.show(...)`.
- 🎯 **Flexible alignment** – display widgets at any screen position (`top`, `bottom`, `center`, etc.).
- 🎨 **Customizable transitions** – `fade`, `scale`, `slide`, `rotate`, or compose your own.
- ✅ **Customizable Alignment**: Display widgets at any position on the screen (top, bottom, center, etc.).
- 🧩 **Composable animations** – chain multiple transitions fluently .`fade().scale().rotation()`.
- 🖼️ **Custom Background**: add custom backgrounds or animated backdrops.
- 👆 **Dismissible overlays** – tap outside to close with ease.
- ⏱️ **Auto-dismiss** – control duration or disable with `Duration.zero`.
- ✅ **Type-safe results** – returns a `Future<T?>` that resolves when the overlay closes.
- ⚡ **Lightweight** – zero dependencies, built on pure **`Flutter`**.

## Usage Examples

<table>
  <tr>
    <th colspan="2" style="text-align: center; font-weight: bold;">
      Simple blue toast that slides up from the bottom and auto-dismisses after 4 seconds.
    </th>
  </tr>
  <tr>
    <td valign="top"><img src="https://raw.githubusercontent.com/nikoro/context_show/main/images/1.gif"  width="200" alt="Simple blue toast that slides up from the bottom and auto-dismisses after 4 seconds demo"/>
    </td>
    <td valign="top">
    <pre><code class="language-dart">
Scaffold(
    body: Center(
      child: ElevatedButton(
        child: Text('Show'),
        onPressed: () => context.show(
          (_) => Container(
            width: double.infinity,
            color: Colors.blue,
            padding: EdgeInsets.symmetric(vertical: 12),
            child: const Text(
              'Simple toast',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
          alignment: Alignment.bottomCenter
        ),
      ),
    ),
  );
  </code></pre></td>
  <tr>
    <th colspan="2" style="text-align: center; font-weight: bold;">
      Green banner that slides down from the top and can be only closed by clicking on the close icon button.
    </th>
  </tr>
  <tr>
    <td valign="top"><img src="https://raw.githubusercontent.com/nikoro/context_show/main/images/2.gif" width="200" alt="Green banner that slides down from the top and can be only closed by clicking on the close icon button demo"/>
    </td>
    <td valign="top">
    <pre><code class="language-dart">
Scaffold(
    body: Center(
      child: ElevatedButton(
        child: Text('Show'),
        onPressed: () => context.show(
          (overlay) => Container(
            width: double.infinity,
            color: Colors.green,
            padding: EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Banner',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
                IconButton(
                  onPressed: overlay.close,
                  icon: Icon(Icons.close),
                  color: Colors.white,
                ),
              ],
            ),
          ),
          alignment: Alignment.topCenter,
          duration: Duration.zero,
        ),
      ),
    ),
  );
 </code></pre></td>
 </tr>
 <tr>
    <th colspan="2" style="text-align: center; font-weight: bold;">
      Showing multiple banners with random color and random alignment and closing them one by one with separate button
    </th>
  </tr>
  <tr>
    <td valign="top"><img src="https://raw.githubusercontent.com/nikoro/context_show/main/images/3.gif"  width="200" alt="Showing multiple banners with random color with random alignment and closing them one by one with separate button demo"/>
    </td>
    <td valign="top">
    <pre><code class="language-dart">
Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            child: Text('Show'),
            onPressed: () {
              final randomColor = Color.fromARGB(
                255,
                random.nextInt(256),
                random.nextInt(256),
                random.nextInt(256),
              );
              final randomAlignment = Alignment(
                random.nextDouble() * 2 - 1,
                random.nextDouble() * 2 - 1,
              );
              context.show(
                (_) => Container(
                  color: randomColor,
                  padding: EdgeInsets.all(12),
                  child: const Text(
                    'Banner',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                alignment: randomAlignment,
                duration: Duration.zero,
              );
            },
          ),
          ElevatedButton(
            child: Text('Close'),
            onPressed: () => context.close(),
          ),
        ],
      ),
    ),
  );
  </code></pre></td>
  </tr>
   <tr>
    <th colspan="2" style="text-align: center; font-weight: bold;">
      Showing Flutter logo in the center with a rotation animation, on a dimmed, dismissible background
    </th>
  </tr>
  <tr>
    <td valign="top"><img src="https://raw.githubusercontent.com/nikoro/context_show/main/images/4.gif"  width="200" alt="Showing Flutter logo in the center with a rotation animation, on a dimmed, dismissible background demo"/>
    </td>
    <td valign="top">
    <pre><code class="language-dart">
Scaffold(
    body: Center(
      child: ElevatedButton(
        child: Text('Show'),
        onPressed: () => context.show(
          (_) => FlutterLogo(size: 200),
          background: (_) => 
              Container(color: Colors.black.withAlpha(100)),
          duration: Duration.zero,
          safeArea: false,
          dismissible: true,
          transition: TransitionBuilders.rotation,
        ),
      ),
    ),
  );
  </code></pre></td>
  </tr>
   <tr>
    <th colspan="2" style="text-align: center; font-weight: bold;">
      Displays a small red banner at the top center, aligned with the app bar and safe area insets. It slides in from below with a rotation effect, over a reddish, dismissible background
    </th>
  </tr>
  <tr>
    <td valign="top"><img src="https://raw.githubusercontent.com/nikoro/context_show/main/images/5.gif"  width="200" alt="Displays a small red banner at the top center, aligned with the app bar and safe area insets. It slides in from below with a rotation effect, over a reddish, dismissible background demo"/>
    </td>
    <td valign="top">
    <pre><code class="language-dart">
Scaffold(
    appBar: AppBar(backgroundColor: Colors.blue),
    body: Builder(
      builder: (context) {
        return Center(
          child: ElevatedButton(
            child: Text('Show'),
            onPressed: () => context.show(
              (overlay) => Container(
                margin: overlay.safeArea.insets,
                padding: EdgeInsets.all(12),
                color: Colors.red,
                child: Text('Banner'),
              ),
              background: (_) => 
                  Container(color: Colors.red.withAlpha(100)),
              safeArea: false,
              dismissible: true,
              alignment: Alignment.topCenter,
              transition: Transition.slideFromBottom().rotation(),
            ),
          ),
        );
      },
    ),
    bottomNavigationBar: Container(color: Colors.blue, height: 100),
  );
  </code></pre></td>
  </tr>               
</table> 
