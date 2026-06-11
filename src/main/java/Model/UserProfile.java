package Model;

public class UserProfile {
    private final Integer heightCm;
    private final Integer weightKg;
    private final Long budgetVnd;

    public UserProfile(Integer heightCm, Integer weightKg, Long budgetVnd) {
        this.heightCm = heightCm;
        this.weightKg = weightKg;
        this.budgetVnd = budgetVnd;
    }

    public Integer getHeightCm() { return heightCm; }
    
    public Integer getWeightKg() { return weightKg; }
    
    public Long getBudgetVnd() { return budgetVnd; }
}