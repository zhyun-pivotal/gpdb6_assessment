# User Guide

(1) download source using zip file (filename : gpdb6_assessment-main.zip)

(2) upload zip file at /home/gpadmin directory in the master node

(3) unzip uploaded file

$ unzip gpdb6_assessment-main.zip

(4) change the directory name

$ mv gpdb6_assessment-main diag

(5) run the diag shell script

$ cd /home/gpadmin/diag

$ sh 0_run_diag.sh

-----------------------------------------------------------------

# Requirement

(1) gpadmin user should have privilege to use sudo command without password

(refernece url : https://docs.vmware.com/en/VMware-Greenplum/6/greenplum-database/install_guide-prep_os.html#topic23)

(2) A version of gpcc 6.x or higher must be installed.

If the gpcc is not installed or in a non-operating state, some of the report resolutions are not generated.

------------------------------------------------------------------

# ユーザーガイド

(1) zipファイルでソースをダウンロード（ファイル名：gpdb6_assessment-main.zip）

(2) マスターノードの /home/gpadmin ディレクトリに zip ファイルをアップロードします

(3) アップロードしたファイルを解凍します

$ gpdb6_assessment-main.zipを解凍します

(4) ディレクトリ名を変更する

$ mv gpdb6_assessment-main diag

(5) diag シェルスクリプトを実行します。

$ cd /home/gpadmin/diag

$ sh 0_run_diag.sh

-----------------------------------------------------------------

# 要件

(1) gpadmin ユーザーには、パスワードなしで sudo コマンドを使用する権限が必要です

(refernece url : https://docs.vmware.com/en/VMware-Greenplum/6/greenplum-database/install_guide-prep_os.html#topic23)
