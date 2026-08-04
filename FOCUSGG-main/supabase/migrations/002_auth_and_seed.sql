create or replace function public.set_updated_at()
returns trigger language plpgsql as $$ begin new.updated_at = now(); return new; end $$;

drop trigger if exists profiles_updated_at on public.profiles;
create trigger profiles_updated_at before update on public.profiles for each row execute function public.set_updated_at();
drop trigger if exists trainings_updated_at on public.trainings;
create trigger trainings_updated_at before update on public.trainings for each row execute function public.set_updated_at();
drop trigger if exists settings_updated_at on public.user_settings;
create trigger settings_updated_at before update on public.user_settings for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
declare candidate text;
begin
  candidate := lower(regexp_replace(coalesce(new.raw_user_meta_data->>'username', split_part(new.email,'@',1)), '[^a-zA-Z0-9_]', '', 'g'));
  if char_length(candidate) < 3 then candidate := 'user_' || left(new.id::text,8); end if;
  if exists(select 1 from public.profiles where username=candidate) then candidate := candidate || '_' || left(new.id::text,4); end if;
  insert into public.profiles(id,username,display_name) values(new.id,candidate,candidate) on conflict(id) do nothing;
  insert into public.user_settings(user_id) values(new.id) on conflict(user_id) do nothing;
  return new;
end $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_user();

insert into public.trainings(id,slug,game,title,level,cognitive_skill,objective,instructions,duration_minutes) values
('11111111-1111-4111-8111-111111111111','aim-gridshot-basico','Aim Lab','Gridshot — controle e ritmo','beginner','Tempo de reação','Construir ritmo e precisão antes de aumentar a velocidade','["Faça um aquecimento de 2 minutos.","Complete três séries de Gridshot.","Descanse 60 segundos entre séries.","Registre a precisão da última série."]',12),
('22222222-2222-4222-8222-222222222222','osu-leitura-consistente','osu!','Leitura visual consistente','intermediate','Foco e atenção','Sustentar a leitura visual com estabilidade','["Escolha um mapa conhecido de dificuldade moderada.","Mantenha postura confortável e volume seguro.","Complete três tentativas com pausa curta.","Registre a accuracy da tentativa final."]',15),
('33333333-3333-4333-8333-333333333333','kovaaks-target-switching','KovaaK''s','Target switching progressivo','intermediate','Tomada de decisão','Alternar prioridades sem sacrificar a precisão','["Abra o cenário Target Switching.","Priorize precisão antes de velocidade.","Complete quatro séries curtas.","Registre o score da melhor série."]',18),
('44444444-4444-4444-8444-444444444444','escape-sala-tempo','Escape Simulator 2','Sala sob restrição de tempo','intermediate','Raciocínio rápido','Organizar pistas e decisões com limite de tempo','["Escolha uma sala ainda não memorizada.","Defina um limite de 25 minutos.","Verbalize prioridades antes de agir.","Registre o tempo de conclusão em segundos."]',25),
('55555555-5555-4555-8555-555555555555','rhythia-padroes','Rhythia','Padrões e antecipação avançada','advanced','Foco e atenção','Antecipar padrões mantendo consistência motora','["Selecione um padrão desafiador, mas executável.","Faça uma tentativa de reconhecimento.","Complete três tentativas válidas.","Registre a precisão da melhor tentativa."]',20)
on conflict(slug) do update set title=excluded.title,objective=excluded.objective,instructions=excluded.instructions,duration_minutes=excluded.duration_minutes,is_active=true;

insert into public.training_metrics(training_id,key,label,unit,value_type,higher_is_better) values
('11111111-1111-4111-8111-111111111111','accuracy','Precisão','%', 'percentage',true),
('22222222-2222-4222-8222-222222222222','accuracy','Accuracy','%', 'percentage',true),
('33333333-3333-4333-8333-333333333333','score','Score','pontos','number',true),
('44444444-4444-4444-8444-444444444444','completion_time','Tempo','segundos','duration',false),
('55555555-5555-4555-8555-555555555555','accuracy','Precisão','%', 'percentage',true)
on conflict(training_id,key) do update set label=excluded.label,unit=excluded.unit,value_type=excluded.value_type,higher_is_better=excluded.higher_is_better;
