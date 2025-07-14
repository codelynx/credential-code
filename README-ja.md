# 🔐 Credential Code

> ビルド時にプレーンテキストの認証情報を暗号化されたコードに変換。もう秘密情報をコミットする心配はありません。

[![Swift](https://img.shields.io/badge/Swift-5.5+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-macOS-blue.svg)](https://www.apple.com/macos)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Languages](https://img.shields.io/badge/Languages-Swift%20%7C%20Kotlin%20%7C%20Java%20%7C%20Python%20%7C%20C++-brightgreen.svg)](#対応言語)

## なぜCredential Code？

**ハードコーディングをやめましょう。** Credential Codeは、ビルド時に認証情報を暗号化し、コミットしても安全な暗号化されたデータを含むソースコードを生成します。秘密情報は実行時にメモリ内でのみ復号化されます。

```mermaid
graph LR
    A[credentials.json<br/>プレーンテキスト] -->|credential-code<br/>生成| B[暗号化コード<br/>コミット可能]
    B -->|アプリ<br/>実行時| C[復号化<br/>メモリ内のみ]
    
    style A fill:#ffcccc
    style B fill:#ccffcc
    style C fill:#ccccff
```

### ⚠️ 重要: セキュリティ上の制限

**このツールはオープンソースプロジェクトには適していません。** 暗号化キーは（難読化されていても）生成されたコードに埋め込まれているため、コードにアクセスできる人は誰でも認証情報を復号化できます。以下の用途でのみ使用してください：
- プライベート/プロプライエタリアプリケーション
- 社内プロジェクト
- クローズドソースのモバイルアプリ
- アクセス制限されたサーバーアプリケーション

### ✨ 主な利点

- 🚫 **ソースコードに秘密情報なし** - バイナリに認証情報が文字列として現れません
- 🔄 **ビルド時暗号化** - 各ビルドで一意の暗号化キーを使用
- 🌍 **マルチ言語サポート** - Swift、Kotlin、Java、Python、C++に対応
- 🛡️ **型安全なアクセス** - マジックストリングなし、コンパイル時チェックされた列挙型
- 📦 **依存関係ゼロ** - 生成されたコードは標準暗号ライブラリのみを使用

## 🚀 クイックスタート

### 1. インストール

```bash
# ソースからビルド
git clone https://github.com/yourusername/credential-code.git
cd credential-code
swift build -c release
sudo cp .build/release/credential-code /usr/local/bin/
```

### 2. プロジェクトを初期化

```bash
cd your-project
credential-code init
```

### 3. 認証情報を追加

`.credential-code/credentials.json`を編集:
```json
{
  "API_KEY": "sk-1234567890abcdef",
  "DATABASE_URL": "postgres://user:pass@localhost/db"
}
```

### 4. 暗号化コードを生成

```bash
# デフォルト: 外部キーと.credsファイルを生成
credential-code generate
# 作成されるファイル:
# - Generated/Credentials.swift (暗号化されたデータ)
# - Generated/credentials.creds (ランタイム用認証情報)
# - .credential-code/encryption-key.txt (暗号化キー)
```

### 5. アプリで使用

```swift
// 外部キーを読み込む
try Credentials.loadKey(from: ".credential-code/encryption-key.txt")

// 認証情報にアクセス
let apiKey = try Credentials.get(.API_KEY)
```

## 📚 完全なドキュメント

- [**インストールガイド**](#インストール) - 詳細なセットアップ手順
- [**使用ガイド**](#使用方法) - 完全なワークフローと例
- [**セキュリティモデル**](#セキュリティ) - 認証情報の保護方法
- [**言語別の例**](#対応言語) - 各言語のコードサンプル
- [**デモプロジェクト**](#デモ) - 実際の動作を確認

## 対応言語

| 言語 | ファイル | 必要なライブラリ | 例 |
|------|---------|-----------------|-----|
| Swift | `Credentials.swift` | CryptoKit (組み込み) | [表示](#swift例) |
| Kotlin | `Credentials.kt` | javax.crypto (組み込み) | [表示](#kotlin例) |
| Java | `Credentials.java` | javax.crypto (組み込み) | [表示](#java例) |
| Python | `credentials.py` | [cryptography](https://pypi.org/project/cryptography/) | [表示](#python例) |
| C++ | `credentials.cpp` | OpenSSL | [表示](#c例) |

## 使用方法

### 初期化

プロジェクトに認証情報ストレージ構造を作成:

```bash
credential-code init
```

これにより作成されるもの:
- `.credential-code/` ディレクトリ
- サンプル構造の`credentials.json`
- `.gitignore`を更新して認証情報を除外

### 認証情報の追加

`.credential-code/credentials.json`を編集:

```json
{
  "STRIPE_KEY": "sk_test_...",
  "AWS_SECRET": "aws_secret_key_...",
  "JWT_SECRET": "your-256-bit-secret"
}
```

**命名規則**: 認証情報キーにはUPPER_SNAKE_CASEを使用してください。

### コード生成

ターゲット言語用の暗号化コードを生成:

```bash
# Swift (デフォルト) - 外部キーと.credsファイルを生成
credential-code generate

# その他の言語
credential-code generate --language kotlin
credential-code generate --language java --output src/main/java/Creds.java

# .credsファイルなしで生成
credential-code generate --no-generate-creds

# 埋め込みキーを使用 (レガシーモード)
credential-code generate --embedded-key --no-generate-creds
```

#### 外部キーモード（デフォルト）

Credential Codeは、セキュリティ向上のため外部キーをデフォルトで使用します:

```bash
# デフォルト: 外部キーで生成
credential-code generate
# 作成されるファイル:
# - Generated/Credentials.swift (暗号化されたデータ)
# - Generated/credentials.creds (ランタイム用認証情報)
# - .credential-code/encryption-key.txt (暗号化キー)

# キーはビルド間で再利用されます
# 初回生成時にキーが表示されます
# コピーしやすいプレーンテキストBase64形式

# 埋め込みキーを使用 (レガシーモード)
credential-code generate --embedded-key --no-generate-creds
```

📖 **[外部キー使用ガイド（英語）](docs/EXTERNAL_KEY_GUIDE.md)** で詳細な使用方法とデプロイ戦略をご覧ください

### 言語別の例

#### Swift例
```swift
import Foundation

// デフォルトモード（外部キー）
// まず、キーを読み込む
try Credentials.loadKey(from: ".credential-code/encryption-key.txt")

// 次に認証情報にアクセス
let apiKey = try Credentials.get(.API_KEY)
let headers = ["Authorization": "Bearer \(apiKey)"]

// 頻繁に使用する認証情報にはキャッシュを使用
let dbUrl = try Credentials.getCached(.DATABASE_URL)

// レガシーモード（埋め込みキー）
if let apiKey = Credentials.decrypt(.API_KEY) {
    // APIキーを使用...
}
```

#### Kotlin例
```kotlin
// 認証情報を復号化
val apiKey = Credentials.decrypt(CredentialKey.API_KEY)
apiKey?.let { key ->
    val headers = mapOf("Authorization" to "Bearer $key")
    // APIリクエストを実行...
}

// キャッシュ付き
val dbUrl = Credentials.decryptCached(CredentialKey.DATABASE_URL)
```

#### Java例
```java
// 認証情報を復号化
String apiKey = Credentials.decrypt(CredentialKey.API_KEY);
if (apiKey != null) {
    Map<String, String> headers = Map.of("Authorization", "Bearer " + apiKey);
    // APIリクエストを実行...
}
```

#### Python例
```python
from credentials import Credentials, CredentialKey

# 認証情報を復号化
api_key = Credentials.decrypt(CredentialKey.API_KEY)
if api_key:
    headers = {"Authorization": f"Bearer {api_key}"}
    # APIリクエストを実行...

# キャッシュ付き
db_url = Credentials.decrypt_cached(CredentialKey.DATABASE_URL)
```

#### C++例
```cpp
#include "credentials.h"

// 認証情報を復号化
auto apiKey = Credentials::decrypt(CredentialKey::API_KEY);
if (apiKey.has_value()) {
    std::string authHeader = "Bearer " + apiKey.value();
    // APIリクエストを実行...
}
```

## デモ

すべての言語の動作を確認する包括的なデモを実行:

```bash
./demo.sh
```

デモの内容:
- テスト認証情報を含むサンプルプロジェクトを作成
- すべての言語用の暗号化コードを生成
- 動作する例を実行
- 完全なワークフローを表示

## セキュリティ

### 仕組み

1. **開発時**: 認証情報をプレーンテキストで`.credential-code/credentials.json`に保存
2. **ビルド時**: ランダムキーを使用して暗号化された認証情報を含むコードを生成
3. **実行時**: アクセス時にメモリ内でのみ認証情報を復号化
4. **バージョン管理**: 暗号化されたコードのみをコミット、プレーン認証情報は決してコミットしない

### セキュリティ機能

- **AES-256-GCM暗号化** 認証付き暗号化
- **ビルドごとに一意のキー** - 各生成で新しいランダムキーを使用
- **難読化されたキー保存** - キーは分割され、実行時に再構築
- **文字列リテラルなし** - バイナリにプレーンテキストとして認証情報が現れない
- **メモリのみの復号化** - 復号化された値は使用中のみ存在

### ベストプラクティス

✅ **すべきこと:**
- `.credential-code/`を`.gitignore`に追加
- プロダクションビルド用に新しいコードを生成
- 環境ごとに異なる認証情報を使用
- 定期的に認証情報をローテーション

❌ **してはいけないこと:**
- `.credential-code/`ディレクトリをコミット
- 開発者間で認証情報ファイルを共有
- 復号化された認証情報値をログ出力
- 必要以上に長く復号化された値を保存
- **オープンソースプロジェクトで使用する** - コードにアクセスできる人は誰でも認証情報を復号化できます

## インストール

### 要件

- **開発**: macOS 12.0+、Swift 5.5+
- **実行時**: ターゲット言語に依存
  - Swift: macOS 11.0+、iOS 14.0+
  - Python: Python 3.7+、`cryptography`パッケージ
  - Java/Kotlin: Java 8+
  - C++: C++17、OpenSSL

### ソースからビルド

```bash
# リポジトリをクローン
git clone https://github.com/yourusername/credential-code.git
cd credential-code

# リリースバージョンをビルド
swift build -c release

# /usr/local/binにインストール
sudo cp .build/release/credential-code /usr/local/bin/

# インストールを確認
credential-code --version
```

## 高度な使用方法

### CI/CD統合

```yaml
# GitHub Actionsの例
- name: Generate Credentials
  run: |
    echo '${{ secrets.CREDENTIALS_JSON }}' > .credential-code/credentials.json
    credential-code generate --language swift
```

### 複数環境

```bash
# 開発
credential-code generate --output Generated/Credentials.dev.swift

# プロダクション
credential-code generate --output Generated/Credentials.prod.swift
```

### カスタム出力パス

```bash
# カスタム出力場所を指定
credential-code generate \
  --language python \
  --output src/config/secure_credentials.py
```

## トラブルシューティング

### よくある問題

**「初期化されていません」エラー**
```bash
# プロジェクトルートで初期化を実行
credential-code init
```

**「無効なキー形式」エラー**
- UPPER_SNAKE_CASEを使用（キー用）
- 文字、数字、アンダースコアのみ

**Python「'cryptography'という名前のモジュールがありません」**
```bash
pip install cryptography
```

## コントリビューション

コントリビューションを歓迎します！ガイドラインは[CONTRIBUTING.md](CONTRIBUTING.md)を参照してください。

### 開発セットアップ

```bash
# リポジトリをクローン
git clone https://github.com/yourusername/credential-code.git
cd credential-code

# Xcodeで開く
open Package.swift

# テストを実行
swift test
```

## ロードマップ

- [ ] パッケージマネージャーサポート（Homebrew、aptなど）
- [ ] GUIアプリケーション
- [ ] VS Code拡張機能
- [ ] 追加言語（Go、Rust、Ruby）
- [ ] クラウドキー管理統合
- [ ] 認証情報ローテーション自動化

## ライセンス

MITライセンス - 詳細は[LICENSE](LICENSE)を参照してください。

## 謝辞

[Swift Argument Parser](https://github.com/apple/swift-argument-parser)と安全なコーディングプラクティスへの愛で構築されました。

---

<p align="center">
  APIキーを削除し忘れた開発者たちによって❤️を込めて作られました
</p>