class StatsModel {
  StatsModel({
    this.inferenceTime = 0,
    this.preProcessingTime = 0,
    this.totalElapsedTime = 0,
    this.totalPredictTime = 0,
  });

  int totalPredictTime;
  int totalElapsedTime;
  int inferenceTime;
  int preProcessingTime;

  @override
  String toString() {
    return 'StatsModel(totalPredictTime: $totalPredictTime, totalElapsedTime: $totalElapsedTime, inferenceTime: $inferenceTime, preProcessingTime: $preProcessingTime)';
  }
}
