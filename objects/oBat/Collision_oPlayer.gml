// Liliecii nu pot fi loviți — dau damage și continuă
with (other)
{
    hp--;
    hp    = max(0, hp);
    flash = 3;
}
instance_destroy();
