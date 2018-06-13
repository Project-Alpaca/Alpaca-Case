IN_TO_MM = 25.4;

function in(length) = length * IN_TO_MM;
function mil(length) = in(length / 1000);
function thou(length) = mil(length);
function ft(length) = in(length)/12;
