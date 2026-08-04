import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = { title: "FOCUS.GG — Treino cognitivo com propósito", description: "Treinos cognitivos orientados usando jogos de PC como ferramenta." };
export default function RootLayout({ children }: Readonly<{children: React.ReactNode}>) {
  return <html lang="pt-BR" suppressHydrationWarning><body>{children}</body></html>;
}
