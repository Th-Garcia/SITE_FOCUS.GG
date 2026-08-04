"use client";
import { FormEvent, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { AlertCircle, ArrowRight, CheckCircle2, Loader2 } from "lucide-react";
import { Logo, ThemeToggle } from "@/components/theme-logo";
import { createSupabaseBrowserClient, isSupabaseConfigured } from "@/lib/supabase/client";

export default function Login() {
  const router = useRouter();
  const [mode, setMode] = useState<"login" | "signup">("login");
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState<{type:"error"|"success";text:string}|null>(null);

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault(); setLoading(true); setMessage(null);
    const data = new FormData(event.currentTarget);
    const email = String(data.get("email") ?? "").trim();
    const password = String(data.get("password") ?? "");
    const username = String(data.get("username") ?? "").trim();
    if (!isSupabaseConfigured) { setLoading(false); router.push("/teste"); return; }
    const supabase = createSupabaseBrowserClient()!;
    if (mode === "login") {
      const { error } = await supabase.auth.signInWithPassword({ email, password });
      if (error) { setMessage({type:"error",text:"Não foi possível entrar. Confira seus dados e tente novamente."}); setLoading(false); return; }
      router.push("/plataforma"); router.refresh();
    } else {
      const { error } = await supabase.auth.signUp({ email, password, options: { data: { username }, emailRedirectTo: `${location.origin}/auth/callback?next=/teste` } });
      setLoading(false);
      setMessage(error ? {type:"error",text:error.message} : {type:"success",text:"Conta criada. Verifique seu e-mail para continuar."});
    }
  }

  return <main className="min-h-screen grid lg:grid-cols-2">
    <section className="hidden lg:flex relative overflow-hidden bg-[#0b0910] text-white p-14 flex-col justify-between"><div className="orb top-[-100px] left-[-100px]"/><Logo/><div className="relative"><p className="eyebrow">Seu progresso começa aqui</p><h1 className="mt-5 text-6xl leading-[.95] tracking-[-.06em] font-black">Treine com<br/><span className="purple">propósito.</span></h1><p className="text-white/60 mt-7 max-w-md leading-relaxed">Descubra seu nível, receba treinos orientados e acompanhe sua evolução com clareza.</p></div><p className="text-xs text-white/40">Projeto educacional • SENAC Nações Unidas</p></section>
    <section className="grid place-items-center p-5 relative"><div className="absolute right-5 top-5"><ThemeToggle/></div><div className="w-full max-w-md"><div className="lg:hidden mb-12"><Link href="/"><Logo/></Link></div><p className="eyebrow">{mode==="login"?"Boas-vindas":"Nova jornada"}</p><h2 className="mt-3 text-4xl tracking-[-.04em] font-black">{mode==="login"?"Acesse sua conta":"Crie sua conta"}</h2><p className="muted mt-2">{mode==="login"?"Continue de onde parou.":"Leva menos de um minuto."}</p>
      {!isSupabaseConfigured&&<div className="surface rounded-xl p-3 mt-6 text-sm muted">Modo de demonstração: o Supabase ainda não foi configurado neste ambiente.</div>}
      {message&&<div className={`rounded-xl p-3 mt-6 text-sm flex gap-2 ${message.type==="error"?"bg-red-500/10 text-red-500":"bg-green-500/10 text-green-500"}`}>{message.type==="error"?<AlertCircle size={18}/>:<CheckCircle2 size={18}/>} {message.text}</div>}
      <form onSubmit={submit} className="mt-8 grid gap-5">{mode==="signup"&&<Field name="username" label="Nome de usuário" type="text" autoComplete="username" placeholder="como quer ser chamado" minLength={3}/>}<Field name="email" label="E-mail" type="email" autoComplete="email" placeholder="voce@exemplo.com"/><Field name="password" label="Senha" type="password" autoComplete={mode==="login"?"current-password":"new-password"} placeholder="mínimo de 8 caracteres" minLength={8}/><button disabled={loading} className="btn btn-primary mt-2">{loading?<Loader2 className="animate-spin" size={18}/>:<>{mode==="login"?"Entrar":"Criar conta"}<ArrowRight size={18}/></>}</button></form>
      <p className="muted mt-7 text-center text-sm">{mode==="login"?"Ainda não tem conta?":"Já possui conta?"} <button onClick={()=>{setMode(mode==="login"?"signup":"login");setMessage(null)}} className="purple font-bold">{mode==="login"?"Criar conta":"Entrar"}</button></p><Link className="muted block text-center text-sm mt-5" href="/">Voltar para o site</Link></div></section>
  </main>;
}
function Field(props:React.InputHTMLAttributes<HTMLInputElement>&{label:string}){const {label,...input}=props;return <label><span className="text-sm font-bold">{label}</span><input required {...input} className="surface mt-2 w-full rounded-xl px-4 py-3 outline-none focus:border-[var(--purple)]"/></label>}
