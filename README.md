# Dijkstra-distance-Based-Correlation-Filter-and-Tracking-Benchmark-for-Industrial-4.0-Application

Introduction
-------
This is the research code for the paper: [Object Detection and Tracking Benchmark in Industry Based on Improved Correlation Filter](https://link.springer.com/article/10.1007/s11042-018-6079-1)，which has been published by Multimedia Tools and Applications - Springer.  

In this paper, we built a video dataset as a new benchmark for industrial 4.0 applications, and we proposed Dijkstra-distance based correlation filters (DBCF) to deal with the various distorted data in complex industrial setting. For tracking experiments, DBCF exceeds the advanced algorithm such as KCF.

Method    | KCF     | DBCF-e   |DBCF-g    |
--------  |:-------:|:--------:|:---------:
Precision | 76.4%   | 80.2%    |79.3%
FPS       | 220.32  | 190.97   |56.76


Benchmark
-------
We built a video dataset as a new benchmark for industrial 4.0 applications. The dataset has 12 sequences and these videos record the scene of automobile industry production line, which can be used for object detection and tracking task.
Downdoad the dataset：https://pan.baidu.com/s/1xAS1DRW1mA__ITKRKFpQDg

Run this code
------- 
**1.** Unzip 'data.zip' to the current directory

**2.** To run this code, just start with 'run_tracker.m'.

**3.** You can change the tracker by choosing 'tracker_kcf', 'tracker_dbcf_e' and 'tracker_dbcf_g'.

Citation
-------
If you find this benchmark and code useful, please consider to cite our paper：
```bibtex
@article{Shangzhen2018Object,
  title={Object detection and tracking benchmark in industry based on improved correlation filter},
  author={Shangzhen Luan and Yan Li and Xiaodi Wang and Baochang Zhang},
  journal={Multimedia Tools and Applications},
  pages={1-14},
  year={2018},
}
```

Acknowledgements
-------
[Henriques](http://www.isr.uc.pt/~henriques/circulant/)，“High-Speed Tracking with Kernelized Correlation Filters“, IEEE Transactions on Pattern Analysis and Machine Intelligence, 2015

Contact
-------
Baochang Zhang
bczhang@buaa.edu.cn