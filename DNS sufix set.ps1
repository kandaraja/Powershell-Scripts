$Computer = @("tcttsbmc01p","tcttsbmc02p","tcttsbmc03p","tettsbmc04p","tcttsbmc05p","tettsbmc06p","tettsbmc7p","tettsbmc8p","tettsbmc10p","tcttsbmc20p","tcttsbmc21p","tcttsbmc23p")
ForEach ($server in $Computer) {
$class = [wmiclass]"\\$server\root\cimv2:win32_networkadapterconfiguration"
$suffixes = ('target.com','corp.target.com','hq.target.com','dist.target.com','stores.target.com','email.target.com','iad2.target.com','ipd2.target.com','iad1.target.com','erf.target.com','wts.target.com','b2b.target.com','sto.target.com','labs.target.com','tgt.com','backup.target.com')
$class.SetDNSSuffixSearchOrder($suffixes)
}
 