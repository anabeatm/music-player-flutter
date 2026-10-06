# Minimal Music Player 🎵

Reprodutor de música minimalista feito em **Flutter**, com login, playlists na nuvem, busca no catálogo do iTunes, letras de músicas e temas personalizáveis.

Projeto desenvolvido para o **sábado letivo** da disciplina de **Desenvolvimento para Dispositivos Móveis (DDM)**, inspirado no projeto do Mitch Koko ([canal no YouTube](https://www.youtube.com/@createdbykoko)).

## 🎥 Apresentação em Vídeo

Demonstração completa do funcionamento do aplicativo e do código-fonte:

▶️ **[Assistir ao vídeo de apresentação](https://drive.google.com/file/d/1WJIcTdxTCamM3s7xsYbLwLkw_1IyFq_s/view?usp=sharing)**

## ✨ Funcionalidades

* **Autenticação** com Firebase Auth: o app mostra a tela de login ou a biblioteca conforme o estado do usuário.
* **Playlists** personalizadas: criar, excluir e adicionar/remover músicas, com imagem de capa.
* **Player completo**: play/pause, próxima, anterior, barra de progresso com *seek*, modo aleatório (*shuffle*) e repetição.
* **Mini player** fixo na parte inferior de todas as telas.
* **Busca** nas músicas das suas playlists.
* **Descobrir**: pesquisa no catálogo do iTunes (prévias de 30s) e adiciona direto a uma playlist.
* **Letras** das músicas, buscadas via lyrics.ovh com fallback para lrclib.net.
* **Favoritos** e **histórico** das últimas 50 músicas tocadas.
* **Temas**: modo claro/escuro e criação de temas com cores próprias.
* **Sincronização na nuvem**: playlists, favoritos e histórico salvos por usuário no Cloud Firestore.
* Adição de músicas locais do dispositivo (seleção de arquivos).

## 🛠️ Tecnologias

| Tecnologia | Uso |
|---|---|
| Flutter / Dart | Interface e lógica |
| Provider | Gerenciamento de estado |
| audioplayers | Reprodução de áudio |
| file_picker / permission_handler | Escolha de arquivos e permissões |
| Firebase Auth | Login |
| Cloud Firestore | Persistência dos dados do usuário |
| http | iTunes Search API e APIs de letras |

## 📁 Estrutura

```
lib/
├── components/   # Drawer, mini player, capa, caixa neumórfica
├── models/       # Song, MyPlaylist, PlaylistProvider
├── pages/        # Auth, Home, Playlist, Song, Search, Discover,
│                 # Favorites, History, Settings, Themes
├── services/     # ITunesService, LyricsService
├── themes/       # Tema claro, escuro e ThemeProvider
├── utils/        # Navegação, MIME type, blob URL (web)
└── main.dart
assets/           # Áudios e capas de exemplo
firestore.rules   # Regras: cada usuário acessa apenas os próprios dados
```

## 🚀 Como Executar

1. Instale o [Flutter SDK](https://docs.flutter.dev/get-started/install).
2. Clone o repositório e entre na pasta do app:

   ```bash
   git clone https://github.com/anabeatm/minimal-music-player.git
   cd minimal-music-player
   ```

3. Instale as dependências:

   ```bash
   flutter pub get
   ```

4. Configure o Firebase (necessário para login e dados na nuvem):

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   Ative o provedor **E-mail/Senha** no Firebase Authentication, crie o banco **Cloud Firestore** e publique as regras de `firestore.rules`.

5. Execute o app:

   ```bash
   flutter run
   ```

## ⚠️ Status

Projeto acadêmico, ainda em desenvolvimento.

---

Feito com muito 💕 e ☕ por **Ana Beatriz**
