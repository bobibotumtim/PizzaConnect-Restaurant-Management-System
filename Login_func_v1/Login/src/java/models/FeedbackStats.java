package models;

public class FeedbackStats {
    private int totalFeedback;
    private double averageRating;
    private int positiveFeedback;
    private int pendingResponse;
    private double positiveRate;
    private int rating5Count;
    private int rating4Count;
    private int rating3Count;
    private int rating2Count;
    private int rating1Count;

    // Default constructor
    public FeedbackStats() {
    }

    // Main constructor (pendingResponse removed)
    public FeedbackStats(int totalFeedback, double averageRating, int positiveFeedback) {
        this.totalFeedback = totalFeedback;
        this.averageRating = averageRating;
        this.positiveFeedback = positiveFeedback;
        this.pendingResponse = 0; // Always 0, kept for backward compatibility
        this.positiveRate = totalFeedback > 0 ? (double) positiveFeedback / totalFeedback * 100 : 0;
    }

    // Full constructor with rating breakdown (pendingResponse removed)
    public FeedbackStats(int totalFeedback, double averageRating, int positiveFeedback,
                        int rating5Count, int rating4Count, int rating3Count, int rating2Count, int rating1Count) {
        this.totalFeedback = totalFeedback;
        this.averageRating = averageRating;
        this.positiveFeedback = positiveFeedback;
        this.pendingResponse = 0; // Always 0, kept for backward compatibility
        this.positiveRate = totalFeedback > 0 ? (double) positiveFeedback / totalFeedback * 100 : 0;
        this.rating5Count = rating5Count;
        this.rating4Count = rating4Count;
        this.rating3Count = rating3Count;
        this.rating2Count = rating2Count;
        this.rating1Count = rating1Count;
    }

    // ===== GETTERS =====
    public int getTotalFeedback() {
        return totalFeedback;
    }

    public double getAverageRating() {
        return averageRating;
    }

    public int getPositiveFeedback() {
        return positiveFeedback;
    }

    public int getPendingResponse() {
        return pendingResponse;
    }

    public double getPositiveRate() {
        return positiveRate;
    }

    public int getRating5Count() {
        return rating5Count;
    }

    public int getRating4Count() {
        return rating4Count;
    }

    public int getRating3Count() {
        return rating3Count;
    }

    public int getRating2Count() {
        return rating2Count;
    }

    public int getRating1Count() {
        return rating1Count;
    }

    // ===== SETTERS =====
    public void setTotalFeedback(int totalFeedback) {
        this.totalFeedback = totalFeedback;
        // Recalculate positive rate when total changes
        this.positiveRate = totalFeedback > 0 ? (double) positiveFeedback / totalFeedback * 100 : 0;
    }

    public void setAverageRating(double averageRating) {
        this.averageRating = averageRating;
    }

    public void setPositiveFeedback(int positiveFeedback) {
        this.positiveFeedback = positiveFeedback;
        // Recalculate positive rate when positive feedback changes
this.positiveRate = totalFeedback > 0 ? (double) positiveFeedback / totalFeedback * 100 : 0;
    }

    public void setPendingResponse(int pendingResponse) {
        this.pendingResponse = pendingResponse;
    }

    public void setPositiveRate(double positiveRate) {
        this.positiveRate = positiveRate;
    }

    public void setRating5Count(int rating5Count) {
        this.rating5Count = rating5Count;
    }

    public void setRating4Count(int rating4Count) {
        this.rating4Count = rating4Count;
    }

    public void setRating3Count(int rating3Count) {
        this.rating3Count = rating3Count;
    }

    public void setRating2Count(int rating2Count) {
        this.rating2Count = rating2Count;
    }

    public void setRating1Count(int rating1Count) {
        this.rating1Count = rating1Count;
    }

    // ===== UTILITY METHODS =====

    /**
     * Get formatted average rating (e.g., "4.2")
     */
    public String getFormattedAverageRating() {
        return String.format("%.1f", averageRating);
    }

    /**
     * Get formatted positive rate (e.g., "85%")
     */
    public String getFormattedPositiveRate() {
        return String.format("%.0f%%", positiveRate);
    }

    /**
     * Get response rate (percentage of feedback that has been responded to)
     */
    public double getResponseRate() {
        if (totalFeedback == 0) return 0;
        int respondedCount = totalFeedback - pendingResponse;
        return (double) respondedCount / totalFeedback * 100;
    }

    /**
     * Get formatted response rate (e.g., "75%")
     */
    public String getFormattedResponseRate() {
        return String.format("%.0f%%", getResponseRate());
    }

    /**
     * Get star rating display for average rating
     */
    public String getAverageStarRating() {
        StringBuilder stars = new StringBuilder();
        int fullStars = (int) averageRating;
        boolean hasHalfStar = (averageRating - fullStars) >= 0.5;
        
        for (int i = 1; i <= 5; i++) {
            if (i <= fullStars) {
                stars.append("★");
            } else if (i == fullStars + 1 && hasHalfStar) {
                stars.append("☆"); // Could be replaced with half-star symbol if available
            } else {
                stars.append("☆");
            }
        }
        return stars.toString();
    }

    /**
     * Get rating level based on average rating
     */
    public String getOverallRatingLevel() {
        if (averageRating >= 4.5) return "Xuất sắc";
        else if (averageRating >= 3.5) return "Tốt";
        else if (averageRating >= 2.5) return "Trung bình";
        else if (averageRating >= 1.5) return "Kém";
        else return "Rất kém";
    }

    /**
     * Check if there are urgent issues (high number of low ratings without response)
     */
    public boolean hasUrgentIssues() {
        int lowRatings = rating1Count + rating2Count;
        return lowRatings > 0 && pendingResponse > 0;
    }

    /**
* Get percentage for each rating level
     */
    public double getRating5Percentage() {
        return totalFeedback > 0 ? (double) rating5Count / totalFeedback * 100 : 0;
    }

    public double getRating4Percentage() {
        return totalFeedback > 0 ? (double) rating4Count / totalFeedback * 100 : 0;
    }

    public double getRating3Percentage() {
        return totalFeedback > 0 ? (double) rating3Count / totalFeedback * 100 : 0;
    }

    public double getRating2Percentage() {
        return totalFeedback > 0 ? (double) rating2Count / totalFeedback * 100 : 0;
    }

    public double getRating1Percentage() {
        return totalFeedback > 0 ? (double) rating1Count / totalFeedback * 100 : 0;
    }

    // ===== toString =====
    @Override
    public String toString() {
        return "FeedbackStats{" +
                "totalFeedback=" + totalFeedback +
                ", averageRating=" + averageRating +
                ", positiveFeedback=" + positiveFeedback +
                ", pendingResponse=" + pendingResponse +
                ", positiveRate=" + positiveRate +
                ", rating5Count=" + rating5Count +
                ", rating4Count=" + rating4Count +
                ", rating3Count=" + rating3Count +
                ", rating2Count=" + rating2Count +
                ", rating1Count=" + rating1Count +
                '}';
    }
}
