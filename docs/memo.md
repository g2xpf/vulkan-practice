# Vulkan のおべんきょ

## 制御フロー

### Instance, Physical Device の設定
- VkInstance: API 拡張, アプリの記述等を行う.
- VkPhysicalDevice: VRAM のサイズや Graphic Card の指定などを行う.

### VkDevice, VkQueue の設定
- VkDevice: マルチビューポートレンダリングや 64bit float の設定を `VkPhysicalDeviceFeatures` に記述する.
- VkQueue: Vulkan 上での描画やメモリ管理は, まず `VkQueue` に命令を送る必要がある.
    - `VkQueue` はあらゆる種類の Queue Family によって生成され, これらは役割ごとに異なる(描画, 計算, メモリ管理等).

### サーフェスとスワップチェーン
- Vulkan はウィンドウの生成を行わないので, GLFW や SDL におまかせする必要がある.
- ウィンドウに対してレンダリングしたいものは主に2種類ある.
    1. VkSurfaceKHR
    2. VkSwapchainKHR
        - KHR が語尾につくやつは, Vulkan Extension の機能.
- グラフィックの作成は Vulkan が, そしてそれをウィンドウに描画するところは GLFW とかが
担う. これは, これが異なるウィンドウマネージャでも同様に動いてくれるようにラップされたAPIだから.
    - Surface は GLFW とかが提供してくれる, 「クロスプラットフォームな処理」を抽象化したもの.
    - Swapchain は描画対象の集まり. vsync やら triple buffering を管理する.
    - VK_KHR_display や VK_KHR_display_swapchain といった拡張機能は, Window Manager によらず
        ウィンドウを生やすことができる. これは, 例えば自分でウィンドウマネージャを作る時などに使える.

### Image Views とフレームバッファ
- swap chain から取り出したイメージは, `VkImageView` と `VkFrameBuffer` に一つ一つつつんであげる必要がある.

### Render passes
- 描画命令中にもちいる, イメージの種類を指定する.
- Render passes はイメージの種類を指定するだけ(未反映)で, `VkFrameBuffer` がこれを反映させる.

### グラフィックス パイプライン
- まず, `VkPipeline` オブジェクトを生成する. これには, ビューポートや depth buffer に
- 対する命令, `VkShaderModule` オブジェクトを指定する.
    - `VkShaderModule` は shader のバイトコードから生成される.
- 気をつけなければならないのが, この `VkPipeline` オブジェクトはパイプラインの構成ごとに一つ一つ別個で作らなければならないという点.
    - ただし,事前コンパイルすることによって runtime-compilation には作用しない,
      ハードウェア固有の最適化をかけることができる. パイプラインが動的に変わらないので.

### Command pool, command buffer
- Queue にコマンドを突っ込んだ後, `VkCommandBuffer` に登録する必要がある. これは `VkCommandPool` から
  アロケーションを行う.
- Because the image in the framebuffer depends on which specific image the swap chain will give us, we need to record a command buffer for each possible image and select the right one at draw time. The alternative would be to record the command buffer again every frame, which is not as efficient.

### メインループ
- `vkAcquireNextImageKHR` によって swap chain からイメージを引き抜き, そのイメージにあった command buffer を
選んだら `vkQueueSubmit` によってイメージを `vkQueuePresentKHR` で swap chain に返す.
- キューに登録された命令は非同期実行されるため, セマフォとかを使って同期を取る必要がある.
- また, `vkQueuePresentKHR` の実行も, 描画が全て終了し終わるまでセマフォで同期を取る必要がある.

### まとめ
めんどっちぃ

## Validation layers
Vulkan は何も設定していないと, デバッグ処理をほとんど行わない. このため, 厳密なパラメータ設定をしてあげないと, よくわからん挙動をしたり簡単に UB を引き起こしたりする. これは Vulkan にデバッグ処理を導入できなかったからではなく, Validation Layers という仕組みがあるからで, これは, 例えば以下のような処理を可能にする.
- 仕様にそぐわないパラメータが渡されていないかを検出する.
- メモリリークを見つけるために, オブジェクトの生成や解放を追跡できるようにする.
- スレッドセーフティを確かめるために, 呼び出し元のスレッドを追跡する.
- 全ての関数呼び出しとパラメータの記録を標準出力へ流す.
- Vulkan の関数呼び出しを追跡する.

また, この Validation layer は Debug Mode でオン, Release Mode でオフにするといった小回りが効くので, とてもべんり.
Validation layer は, 例えば Vulkan SDK に入っているものであれば, これがない環境では動かない.
