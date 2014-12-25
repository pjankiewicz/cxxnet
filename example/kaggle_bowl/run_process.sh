#!/bin/bash

DATAPATH=/home/pawel/projects/kaggle/plankton

python gen_img_list.py train $DATAPATH/sample_submission.csv $DATAPATH/train/ img_train.lst
python gen_img_list.py test $DATAPATH/sample_submission.csv "$DATAPATH/test/*/*.jpg" img_test.lst

python gen_train.py $DATAPATH/train/ $DATAPATH/train_48x48/
python gen_train.py $DATAPATH/test/ $DATAPATH/test_48x48/

../../tools/im2bin img_train.lst ./ train.bin
../../tools/im2bin img_test.lst ./ test.bin

mkdir models

python make_submission.py /home/pawel/projects/kaggle/plankton/sample_submission.csv test.lst test.txt out.csv
