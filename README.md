# 概要
確認日時、サーバアドレス、応答結果がカンマ区切りで1行ずつ記載されているログファイルをもとに下記の4つの確認を行うことが出来るプログラムです。

1. 監視ログファイルを読み込み、故障状態のサーバアドレスとそのサーバの故障期間をコンソール上に出力します。
なお、pingがタイムアウトした場合を故障とみなし、最初にタイムアウトしたときから次にpingの応答が返るまでを故障期間としています。
2. 1に加えてネットワークの状態によっては、一時的にpingがタイムアウトしても一定期間するとpingの応答が復活することがあります。
   そのような場合はサーバの故障とみなさないようにして結果を出力します。
3. サーバが返すpingの応答時間が長くなる場合、サーバが過負荷状態になっていると考えられます。
   そこで、直近m回の平均応答時間がtミリ秒を超えた場合はサーバが過負荷状態になっているとみなしコンソール上に出力します。
4. ネットワーク経路にあるスイッチに障害が発生した場合、そのスイッチの配下にあるサーバの応答がすべてタイムアウトすると想定されます。
   そこで、あるサブネット内のサーバが全て故障（ping応答がすべてN回以上連続でタイムアウト）している場合は
   そのサブネット（のスイッチ）の故障とみなしコンソール上で出力します。

## 前提
以下を前提として付け加えさせて頂きます。

1. 渡されるファイルの拡張子はCSVである。
2. ログは時系列で古い順で並んでいる。
3. ログファイルの各行には必ず日時・サーバアドレス・レスポンスの順番で並んでいる。
4. 日時・サーバアドレス・レスポンスの3つはそれぞれ必ず指定のフォーマットで出力されているとする。
5. サブネットマスクは8,16,24のいずれかである。

## 本プログラムの動かし方
1. 本ディレクトリの直下にcsv形式のログファイルを置いてください。
2. コンソール上で「ruby main.rb」と入力してEnterを押して頂くと最初にファイル名の入力を求められます。そこで先ほど置かれたファイルの拡張子を抜いた部分(例.log.csvならlog)と入力してEnterと押してください。
3. 確認したい内容によって入力する項目は変わりますがいずれも半角数字を入力してEnterを押して進めていってください。なお、文字、負の数などを入力されるとエラーを起こしプログラムは終了されるのでご注意ください。
4. 結果が出力されプログラムが終了します。

デモ動画を一番下に添付しておりますので、もし良ければそちらもご覧ください。

## プログラム構成
- 使用言語
  - Ruby 2.7
  - 公式ドキュメントは[こちら](https://docs.ruby-lang.org/ja/3.0/doc/index.html) です。
- テストフレームワーク
  - RSpec
- main.rb
  - こちらではCSVがあるか、ユーザーが入力した値は正しいかなどを確認して後述するLogReaderクラスに処理を受け渡します。
- srcディレクトリ
  - 確認用のプログラムが含まれております。
  - log_reader.rb
    - 上記1~4の確認はこちらのLogReaderクラスで行われます。確認1と2に対応したメソッド、3に対応したメソッド、4に対応したメソッドがあります。
      - not_working_serversメソッド
        - こちらは確認1と2の実質的な処理を行っているクラスです。(display_not_working_serversはこのメソッドの結果を出力しているだけです。分けないと自動テストを行いづらいと考え、そうしました。)
        - ログを1行ずつ確認してサーバの状態を更新していき、サーバが故障状態から復旧したらその内容を戻り値用の変数に格納していきます。
        - サーバの状態についてはにServerクラスがあり、そちらで管理しているのでこちらでは処理を呼ぶだけになります。
      - overloaded_serversメソッド
        - こちらは確認3の実質的な処理を行っているクラスです。
        - ログを1行ずつ確認してログが規定回数溜まったら都度平均値が指定された数値を確認して超えていたら戻り値用の変数に格納します。
        - 平均数値についてはResponseArrayというクラスが各Server内にあり、そちらで管理しておりますのでこちらのメソッド内では処理を呼ぶだけになります。
      - not_working_networks
        - こちらは確認4の実質的な処理を行っているクラスです。
        - ログを1行ずつ確認してネットワーク内のサーバが全て故障したかどうかを確認して、故障していたら戻り値用の変数に格納します。
        - ネットワーク内のサーバの状態についてはNetworkクラスとServerクラスで管理しておりますので、こちらでは処理を呼ぶ・確認するのみとなります。
  - log.rb
    - logに関する情報を持っているクラスです。
  - log_reader_factory.rb
    - LogReaderクラスとそれに関わるNetworkなどのクラスも作成します。
    - Serverクラスは設問ごとに異なる属性(N回連続でタイムアウトしたら故障、直近m回の平均値を出すなど)が必要なのでこちらのクラスで全ての属性を管理してServerクラスのコンストラクタはメンバ変数に代入するだけにした。
  - network.rb
    - ネットワークごとのサーバの挙動を管理するクラスです。正常に動いているか、いつから故障しているかなどを管理します。
  - server.rb
    - 各サーバの状態を管理するクラスです。正常に動いているか過負荷になっていないかなどを管理します。なお過負荷になっているかどうかのロジックは後述するresponse_arrayクラスの責務でserverクラスは処理を呼び出しているだけです。
  - response_array.rb
    - 直近m回の平均値を算出します。
    - 平均値を出すaverageメソッドの他に要素を新たに加えるpushメソッド、キャパシティを超えていないか確認するis_full?メソッドなどがあります。
- specディレクトリ
  - テストに関するファイルが含まれています。

## テスト
- spec/log_reader_spec.rbというファイルに自動テストが書かれております。
- 実行コマンド
  - rspec

## デモ
https://user-images.githubusercontent.com/42457215/153734186-8c2f9363-bc0c-490c-b113-94a65a644778.mov



