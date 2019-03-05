module Xanthus
CAMFLOW_START = %q{%{
camflow -a true
sleep 1
}}

CAMFLOW_STOP = %q{%{
camflow -a false
sleep 20
}}

SPADE_START = %q{%{
echo spade | sudo -H -u spade ../SPADE/bin/spade start
sleep 1
}}

SPADE_STOP = %q{%{
echo spade | sudo -H -u spade ../SPADE/bin/spade stop
sleep 20
}}
end
