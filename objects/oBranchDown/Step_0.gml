// Când jucătorul trece prin trigger, crengile din stânga cad în val
if (place_meeting(x, y, oPlayer))
{
    var _tx = x;
    var _i  = 0;
    with (oBranchBase)
    {
        if (x < _tx && !was_triggered && (state == "idle" || state == "up"))
        {
            if (state == "idle")
                y = y_risen;
            drop_delay    = _i * 10;
            state         = "drop_wait";
            was_triggered = true;
            _i++;
        }
    }
    instance_destroy();
}
