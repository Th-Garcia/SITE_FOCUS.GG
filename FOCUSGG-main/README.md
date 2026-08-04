# FOCUS.GG

Plataforma educacional de treinamento cognitivo orientado com jogos de PC.

## Rodar localmente

1. Crie ou conecte um projeto Supabase e execute as migrações em `supabase/migrations`, na ordem numérica.
2. Copie `.env.example` para `.env.local` e preencha a URL e a chave pública do Supabase.
3. No Supabase Auth, adicione `http://localhost:3000/auth/callback` aos Redirect URLs.
4. Execute `npm install` e `npm run dev`.
5. Adicione `public/FOCUS.GG.png` e `public/FOCUS.GG_branco.png` para substituir o fallback tipográfico.

Sem variáveis do Supabase, o projeto funciona em modo demonstrativo. Com as variáveis configuradas, autenticação, teste inicial, perfil, senha, avatar, preferências e resultados usam o backend real com RLS.

## Erro `react/jsx-runtime` ou `JSX.IntrinsicElements`

Esse aviso significa que as dependências ainda não foram instaladas na cópia local. Abra o terminal na mesma pasta que contém `package.json` e execute:

```powershell
npm install
npm run dev
```

Se o projeto foi baixado como ZIP, confirme que o terminal está na pasta interna `FOCUSGG-main` que contém o arquivo `package.json`. Depois da instalação, use **TypeScript: Restart TS Server** na paleta de comandos do VS Code caso os sublinhados permaneçam visíveis.
